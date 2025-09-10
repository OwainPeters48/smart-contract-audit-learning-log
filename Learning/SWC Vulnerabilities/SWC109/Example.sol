// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
================================================================================
SWC-109: Uninitialized Storage Pointer — Deep Dive (Modern + Legacy Showcase)
================================================================================

Attack narrative (legacy bug):
1) Dev writes a function that declares a struct as a *storage* local variable
   but FORGETS to initialise it (e.g., `User storage u;`).
2) In legacy compilers, `u` may point to storage slot 0 by default.
3) Writing to `u` overwrites slot 0, which often stores `owner` or other
   critical variables.
4) Attacker calls that function and corrupts `owner`, escalating privileges.
*/

contract Good {
    // Critical state in early slots
    address public owner;
    mapping(address => User) public users;

    struct User {
        uint256 balance;
        uint256 lastUpdated;
    }

    event Deposited(address indexed account, uint256 amount);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // Correct pattern: bind storage explicitly to a real slot (mapping entry).
    function deposit() external payable {
        require(msg.value > 0, "no value");
        // EXPLICITLY INITIALISED STORAGE REFERENCE (✅ correct):
        User storage u = users[msg.sender];

        // ❌ UNINITIALISED STORAGE POINTER (SWC-109):
        // User storage u;   // <-- BUG: this "u" may point to slot 0 by default.

        u.balance += msg.value;
        u.lastUpdated = block.timestamp;
        emit Deposited(msg.sender, msg.value);
    }

    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero addr");
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
    }

    // Helper for demos/tests
    function getUser(address who) external view returns (uint256 balance, uint256 lastUpdated) {
        User storage u = users[who];
        return (u.balance, u.lastUpdated);
    }
}

