// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title RequireProperly
 * @dev Fixes misuse of `assert` by using `require` for user-facing errors
 */
contract RequireProperly {
    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public totalMinted;

    function mint(uint256 amount) external {
        require(totalMinted + amount <= MAX_SUPPLY, "Exceeds max supply");

        totalMinted += amount;
    }
}
