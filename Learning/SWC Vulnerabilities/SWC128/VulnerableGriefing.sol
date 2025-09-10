// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
    What's vulnerable here?
    - Unbounded loop over `members` → gas grows linearly with size
    - Attacker can bloat `members` list via Sybil joins
    - Once too large, distributeRewards() exceeds block gas limit → permanently uncallable
    - require(ok) means one failed send reverts the entire loop (compounds DoS risk)
*/

contract GasGriefingRewards {
    address public owner;
    address[] public members;
    mapping(address => uint256) public pending;

    modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }

    constructor() { owner = msg.sender; }

    function join() external {
        // Attacker can cheaply spam this function with many accounts
        members.push(msg.sender);
    }

    receive() external payable {}

    function distributeRewards() external onlyOwner {
        uint256 share = address(this).balance / members.length;
        for (uint256 i = 0; i < members.length; i++) {
            (bool ok, ) = members[i].call{value: share}("");
            require(ok, "send failed");
        }
    }
}
