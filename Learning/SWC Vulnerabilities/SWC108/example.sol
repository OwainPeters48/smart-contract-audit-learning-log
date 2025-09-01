// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ExampleVulnerable {
    uint balance; // no visibility explicitly set
}

contract ExampleFixed {
    uint private balance; // explicitly marked
}
