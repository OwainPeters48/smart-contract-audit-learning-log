// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Griefer {
    // Revert on receiving ETH -> breaks refundAll()
    receive() external payable { revert("nope"); }
}
