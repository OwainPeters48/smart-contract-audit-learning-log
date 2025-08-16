// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract VulnerableBank {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // 🚨 Visibility not set → defaults to PUBLIC in <0.5.0
    function withdrawAll() {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}
