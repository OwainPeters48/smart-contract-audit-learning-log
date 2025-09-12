// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title SWC-119: Shadowing State Variables (good example)

contract Parent {
    address internal owner;
}

contract Child is Parent {
    function setOwner(address _owner) public {
        owner = _owner; // safely updates Parent.owner
    }

    function getOwner() public view returns (address) {
        return owner;
    }
}
