// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract FakeOracle {
    uint256 public price;

    constructor(uint256 _initial) {
        price = _initial;
    }

    function setPrice(uint256 _p) external {
        price = _p;
    }

    function getPrice() external view returns (uint256) {
        return price;
    }
}