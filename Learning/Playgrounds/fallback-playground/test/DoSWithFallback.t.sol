// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Victim.sol";
import "../src/Attacker.sol";
import "../src/VictimFixed.sol";

contract DoSWithFallbackTest is Test {
    Attacker attacker;
    Victim victim;
    VictimFixed victimFixed;

    address payable alice = payable(address(0x1001));
    address payable bob   = payable(address(0x1002));
    address payable attackerAddr;

    function setUp() public {
        // deploy attacker contract
        attacker = new Attacker();
        attackerAddr = payable(address(attacker));

        // deploy vulnerable Victim by passing three addresses explicitly
        victim = new Victim(alice, attackerAddr, bob);
        // fund the contract so transfer(1 ether) has funds
        vm.deal(address(victim), 3 ether);

        // deploy fixed Victim, credits balances in constructor
        victimFixed = new VictimFixed(alice, attackerAddr, bob);
        vm.deal(address(victimFixed), 3 ether);

        // reset balances of EOAs
        vm.deal(alice, 0);
        vm.deal(bob, 0);
        vm.deal(attackerAddr, 0);
    }

    function testDoS_RevertsOnPushLoop() public {
        vm.expectRevert(bytes("attacker blocks payments"));
        victim.payAll();
    }

    function testPullWithdraw_OnlyAttackerFails() public {
        vm.prank(alice);
        victimFixed.withdraw();
        assertEq(alice.balance, 1 ether);

        vm.prank(attackerAddr);
        vm.expectRevert(bytes("withdraw failed"));
        victimFixed.withdraw();

        vm.prank(bob);
        victimFixed.withdraw();
        assertEq(bob.balance, 1 ether);
    }
}
