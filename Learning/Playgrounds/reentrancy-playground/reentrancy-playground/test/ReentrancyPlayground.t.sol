// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/ReentrancyPlayground.sol";

contract ReentrancyTest is Test {
    ReentrancyPlayground playground;
    Attacker attacker;

    address alice = address(0xA11ce);
    address attackerEOA = address(0xBEEF);

    function setUp() public {
        playground = new ReentrancyPlayground(address(0), address(0));

        vm.deal(alice, 10 ether);
        vm.prank(alice);
        (bool ok, ) = payable(address(playground)).call{value: 5 ether}(abi.encodeWithSignature("fund()"));
        require(ok, "fund() failed");

        vm.prank(attackerEOA);
        attacker = new Attacker(payable(address(playground)));
    }


    function test_simpleCallWithdraw_vulnerable() public {
        // attacker deposits 2 ETH so it has balance to withdraw
        vm.deal(attackerEOA, 3 ether);
        vm.prank(attackerEOA);
        attacker.depositToTarget{value: 2 ether}();

        // record playground balance before
        uint before = address(playground).balance;
        // start attack: attacker calls attackWithdraw(1 ether)
        vm.prank(attackerEOA);
        attacker.attackWithdraw(1 ether);

        // after attack, playground should have lost ETH if vulnerable
        uint balanceAfter = address(playground).balance;
        emit log_named_uint("before", before);
        emit log_named_uint("after", balanceAfter);

        // in vulnerable contract we expect after < before (drained)
        assertTrue(balanceAfter < before, "Playground should have lost funds");
    }

    function test_optimisticTransferWithdraw_vulnerable() public {
        vm.deal(attackerEOA, 3 ether);
        vm.prank(attackerEOA);
        attacker.depositToTarget{value: 2 ether}();

        uint before = address(playground).balance;

        vm.prank(attackerEOA);
        attacker.attackOptimisticTransfer(1 ether);

        uint afterBal = address(playground).balance;
        emit log_named_uint("before", before);
        emit log_named_uint("after", afterBal);

        assertTrue(afterBal < before, "ETH should be drained");
    }

}
