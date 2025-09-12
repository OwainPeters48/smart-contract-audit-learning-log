// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title AssertViolation
 * @dev Demonstrates misuse of `assert` which causes a Panic(0x01) on failure
 */
contract AssertViolation {
    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public totalMinted;

    function mint(uint256 amount) external {
        totalMinted += amount;

        // @audit panic: assert triggers 0x01 if totalMinted > MAX_SUPPLY
        assert(totalMinted <= MAX_SUPPLY);
    }
}
