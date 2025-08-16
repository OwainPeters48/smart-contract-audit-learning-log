// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeBank {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // ✅ Explicit visibility set
    function withdrawAll() external {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    // Example of internal-only helper
    function _resetBalance(address user) internal {
        balances[user] = 0;
    }
}
