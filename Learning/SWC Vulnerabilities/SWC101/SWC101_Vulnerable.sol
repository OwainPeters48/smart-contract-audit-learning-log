// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12; // <0.8.0 for vulnerable demo

/*
    SWS-101 Vulnerable Examples
    This file contains:
    - Example 1: Underflow
    - Example 2: Overflow
    - Example 3: Token accounting bug
*/

contract SWC101_Vulnerable {
    uint8 public underflowVar = 0;
    uint8 public overflowVar = 255;
    mapping(address => uint256) public balances;

    function underflow(uint8 amount) external {
        underflowVar -= amount;
    }

    function overflow() external {
        overflowVar += 1;
    }

    function badTransfer(address to, uint256 amount) external {
        balances[msg.sender] -= amount; // underflow creates huge balance
        balances[to] += amount;
    }
}