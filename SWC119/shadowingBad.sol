// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/// @title SWC-119: Shadowing State Variables (bad example)

contract Parent {
    address internal owner; // declared once
}

contract Child is Parent {
    address internal owner; // ❌ silently shadows parent variable

    function setOwner(address _owner) public {
        owner = _owner; // only updates Child.owner, not Parent.owner
    }
}
