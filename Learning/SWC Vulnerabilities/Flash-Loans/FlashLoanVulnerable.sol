// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    Vulnerable Lending Protocol
    - Uses a naive AMM spot price as the oracle.
    - Attackers can flash loan tokens, manipulate pool price,
      and borrow against inflated collateral.
*/

/*
    What goes wrong?
    - Attacker flash loans a large amount of collateral
    - Pushes up the AMM spot price by swapping aggressively
    - Calls `borrow()`, which uses teh inflated oracle price
    - Borrows way more `loanToken` than their collateral is really worth
    - Repays the flash loan, keeps the excess profit
*/

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address user) external view returns (uint256);
}

interface IAMMPool {
    function getPrice(address token) external view returns (uint256);
}

contract VulnerableLending {
    IERC20 public collateralToken;
    IERC20 public loanToken;
    IAMMPool public priceOracle;

    mapping(address => uint256) public collateralDeposits;

    constructor(IERC20 _collateral, IERC20 _loan, IAMMPool _oracle) {
        collateralToken = _collateral;
        loanToken = _loan;
        priceOracle = _oracle;
    }

    function depositCollateral(uint256 amount) external {
        require(amount > 0, "invalid amount");
        collateralToken.transferFrom(msg.sender, address(this), amount);
        collateralDeposits[msg.sender] += amount;
    }

    function borrow(uint256 loanAmount) external {
        uint256 collateralValue = collateralDeposits[msg.sender] 
            * priceOracle.getPrice(address(collateralToken));

        require(collateralValue >= loanAmount, "Not enough collateral");
        loanToken.transfer(msg.sender, loanAmount);
    }
}
