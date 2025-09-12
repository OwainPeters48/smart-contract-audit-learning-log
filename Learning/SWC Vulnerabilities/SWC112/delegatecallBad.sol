// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title SWC-112: Delegatecall to Untrusted Callee (vulnerable example)
/// @notice Uses delegatecall to any arbitrary address — storage hijack risk

contract DelegateCallBad {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    /// @notice Anyone can run ANY code in this contract’s storage context
    function execute(address callee, bytes calldata data) external {
        // Vulnerable: delegatecall to user-supplied address
        (bool success, ) = callee.delegatecall(data);
        require(success, "delegatecall failed");
    }
}