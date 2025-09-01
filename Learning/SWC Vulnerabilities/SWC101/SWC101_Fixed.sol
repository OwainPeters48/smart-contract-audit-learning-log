// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24; // auto overflow/underflow checks

/*
    SWS-101 Fixed Examples
    This file contains:
    - Example 1: Underflow fix
    - Example 2: Overflow fix
    - Example 3: Token accounting fix
*/

contract SWC101_Fixed {
    uint8 public underflowVar = 0;
    uint8 public overflowVar = 255;
    mapping(address => uint256) public balances;

    function safeUnderflow(uint8 amount) external {
        require(amount <=underflowVar, "underflow");
        unchecked { underflowVar -= amount; }
    }

    function safeOverflow() external {
        require(overflowVar < type(uint8).max, "overflow");
        unchecked { overflowVar += 1; }
    }

    function safeTransfer(address to, uint256 amount) external {
        uint256 bal = balances[msg.sender];
        require(bal >= amount, "insufficient balance");
        balances[msg.sender] = bal - amount;
        balances[to] += amount;
    }
}