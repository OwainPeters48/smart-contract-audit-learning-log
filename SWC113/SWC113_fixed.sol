// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Refund_PullPattern {
    mapping(address => uint256) public pending;

    function seed(address[] calldata addrs, uint256 amountEach) external payable {
        require(msg.value == amountEach * addrs.length, "bad funding");
        for (uint i; i < addrs.length; i++) {
            pending[addrs[i]] += amountEach;
        }
    }

    // Each user withdraws in their own tx (no loop, no global DoS)
    function withdraw() external {
        uint256 amt = pending[msg.sender];
        require(amt > 0, "nothing to withdraw");
        pending[msg.sender] = 0; 
        (bool ok, ) = payable(msg.sender).call{value: amt}("");
        require(ok, "withdraw failed"); // only affects caller
    }

    receive() external payable {}
}
