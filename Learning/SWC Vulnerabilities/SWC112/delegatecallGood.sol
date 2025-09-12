// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title SWC-112: Delegatecall to Untrusted Callee (fixed example)
/// @notice Restricts delegatecall to trusted implementation only

contract DelegateCallBad {
    address public owner;
    address public trustedImplementation;

    constructor(address _impl) {
        owner = msg.sender;
        trustedImplementation = _impl;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }
    
    
    /// @notice Only delegatecall to the known good implementation
    function execute(bytes calldata data) external onlyOwner {
        (bool success, ) = trustedImplementation.delegatecall(data);
        require(success, "delegatecall failed");
    }
}