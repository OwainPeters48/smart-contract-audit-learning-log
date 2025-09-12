// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract Ownable {
    address public owner;

    // typo: constructor should be "Ownable"
    function Owanble() public {
        owner = msg.sender;
    }
}

contract OwnableFixed {
    address public owner;

    // Correct constructor name
    function OwnableFixed() public {
        owner = msg.sender;
    }
}