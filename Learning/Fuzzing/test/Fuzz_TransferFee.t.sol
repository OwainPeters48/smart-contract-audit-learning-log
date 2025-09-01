// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "weird/TransferFee/TransferFee.sol";

contract Fuzz_TransferFee is Test {
    TransferFeeToken token;

    function setUp() public {
        // totalSupply = 1_000_000, fee = 10
        token = new TransferFeeToken(1_000_000, 10);
        token.approve(address(this), type(uint256).max);
    }

    function testFuzz_Conservation(address to, uint256 amount) public {
        // Assume valid inputs
        vm.assume(to != address(0));
        vm.assume(to != address(this));
        vm.assume(amount <= token.balanceOf(address(this)));

        // Compute fee + expected before state changes
        uint256 fee = (amount * token.feeBps()) / 10_000;
        uint256 expectedReceived = amount > fee ? amount - fee : 0;

        // This must come before token.transfer to avoid state changes during a rejected fuzz case
        uint256 beforeTo = token.balanceOf(to);
        vm.assume(type(uint256).max - beforeTo >= expectedReceived);

        // Snapshot balances
        uint256 beforeSender = token.balanceOf(address(this));
        uint256 beforeSupply = token.totalSupply();

        // Run the transfer
        token.transfer(to, amount);

        // Assertions
        // assertEq(a, b, message) means "Check if a == b, if not, fail the test and print message".
        assertEq(token.balanceOf(address(this)), beforeSender - amount, "sender balance mismatch");
        assertEq(token.balanceOf(to), beforeTo + expectedReceived, "recipient did not get expected");
        assertEq(token.totalSupply(), beforeSupply - fee, "Mismatch in total supply after transfer");
    }

    /*
    Fuzzing results:
    [PASS] testFuzz_Conservation(address,uint256) (runs: 257, μ: 64862, ~: 66651)
    */
}

