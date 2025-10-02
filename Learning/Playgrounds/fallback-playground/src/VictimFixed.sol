// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VictimFixed {
    mapping(address => uint256) public balances;

    // accept exactly three payees and credit them (no array in test)
    constructor(address _a, address _b, address _c) payable {
        balances[_a] += 1 ether;
        balances[_b] += 1 ether;
        balances[_c] += 1 ether;
    }

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "nothing to withdraw");
        balances[msg.sender] = 0;
        (bool ok, ) = payable(msg.sender).call{value: amt}("");
        require(ok, "withdraw failed");
    }

    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
