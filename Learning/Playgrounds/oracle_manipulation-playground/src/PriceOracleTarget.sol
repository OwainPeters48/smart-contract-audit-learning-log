// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IOracle {
    function getPrice() external view returns (uint256); 
}

contract PriceOracleTarget {
    IOracle public oracle;
    mapping(address => uint256) public usdBalance;

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }

    // User deposits ETH recorded as USD using oracle price
    function deposit() external payable {
        require(msg.value > 0, "zero deposit");
        uint256 p = oracle.getPrice();
        usdBalance[msg.sender] += msg.value * p;
    }

    // User withdraws ETH, converted back using *current* oracle price
    function withdraw() external {
        uint256 p = oracle.getPrice();
        uint256 usd = usdBalance[msg.sender];
        require(usd > 0, "zero balance");

        uint256 ethOut = usd / p; // vulnerable if attacker manipulates price
        usdBalance[msg.sender] = 0;

        payable(msg.sender).transfer(ethOut);
    }

    receive() external payable{}
}