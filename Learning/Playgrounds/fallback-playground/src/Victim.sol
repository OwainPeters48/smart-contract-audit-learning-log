// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Victim {
    address[] public payees;

    // accept exactly three payees (avoids array construction in tests)
    constructor(address _a, address _b, address _c) {
        payees.push(_a);
        payees.push(_b);
        payees.push(_c);
    }

    // naive payout function: sends 1 ETH to each payee in a loop
    function payAll() public payable {
        for (uint i = 0; i < payees.length; i++) {
            payable(payees[i]).transfer(1 ether);
        }
    }

    function payeeCount() public view returns (uint) {
        return payees.length;
    }
}
