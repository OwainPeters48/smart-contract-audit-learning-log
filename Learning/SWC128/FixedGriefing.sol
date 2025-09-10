// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
    Why is this safer?
    - No unbounded loop in a single transaction
    - Users pay their own gas to claim (pull payments)
    - Batch operations are limited to a fixed number of users (pagination)
    - Single failed withdraw does not block others
*/

contract RewardsPullWithPagination {
    address public owner;
    address[] public members;
    mapping(address => bool) public isMember;
    mapping(address => uint256) public pending;

    modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }

    constructor() { owner = msg.sender; }

    function join() external {
        require(!isMember[msg.sender], "already member");
        isMember[msg.sender] = true;
        members.push(msg.sender);
    }

    receive() external payable {}

    // ✅ Each user withdraws their own funds
    function withdraw() external {
        uint256 amount = pending[msg.sender];
        require(amount > 0, "nothing to withdraw");
        pending[msg.sender] = 0;
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "withdraw failed");
    }

    // ✅ Optional pagination: owner can batch process in slices
    function batchDistribute(uint256 start, uint256 limit) external onlyOwner {
        uint256 end = start + limit;
        if (end > members.length) end = members.length;

        uint256 share = address(this).balance / members.length;

        for (uint256 i = start; i < end; i++) {
            address user = members[i];
            pending[user] += share;
        }
    }
}

