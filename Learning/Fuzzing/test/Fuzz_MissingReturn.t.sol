// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol"; 
import {MissingReturnToken} from "weird/MissingReturnValues/MissingReturnValues.sol";

contract Fuzz_MissingReturn is Test {
    MissingReturnToken t;

    function setUp() public {
        t = new MissingReturnToken(1_000_000 ether);
    }

    //Property: sum(sender + receiver) doesn't change after transfer
    function testFuzz_Conservation(address to, uint256 amount) public {

        // Precondition 1: can't transfer to the zero address in our demo
        vm.assume(to != address(0));

        // Precondition 2: clamp amount so we don't underflow the sender
        uint256 senderBefore = t.balanceOf(address(this));
        amount = bound(amount, 0, senderBefore);

        // Snapshot the sum of the two accounts we'll touch
        uint256 sumBefore = t.balanceOf(address(this)) + t.balanceOf(to);

        // Call transfer - IMPORTANT: this token returns *no bool*, and that's fine
        t.transfer(to, amount);

        // Re-check balances after transfer
        uint256 sumAfter = t.balanceOf(address(this)) + t.balanceOf(to);

        // Oracle: the property we assert must always hold
        assertEq(sumAfter, sumBefore, "sum changed (should not)");
    }

    /*
    Fuzzing results:
    [PASS] testFuzz_Conservation(address,uint256) (runs: 256, μ: 52318, ~: 52332)
    All test cases passed, meaning the assertions held true for all random inputs.
    runs: 256 - Foundry ran this fuzz 256 times, each with a different random combination of
        - an address
        - a uint256 value
    */
}