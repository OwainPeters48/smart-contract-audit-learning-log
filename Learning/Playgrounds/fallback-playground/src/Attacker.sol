// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Attacker {
    // fallback() executes when the contract receives ETH with data
    // or when a non-existent function is called.
    fallback() external payable {
        // deliberately revert to block the caller that attempted a transfer
        revert("attacker blocks payments");
    }

    // This contract exposes its own address cheaply
    function getAddress() external view returns (address) {
        return address(this);
    }
}
    