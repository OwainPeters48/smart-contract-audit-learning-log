// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    What's vulnerable here?
    - Relies directly on a manipulable AMM spot price for collateral valuation
    - No time-weighted average (TWAP) or trusted oracle integration
    - Allows 100% Loan-to-Value borrowing with no buffer
    - Attackers can flash loan, push up price in a single block, then borrow against inflated collateral
*/

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IAMMOracle {
    function spotPrice(address token) external view returns (uint256);
}

contract OracleManipulationVulnerable {
    IERC20 public collateralToken;
    IERC20 public loanToken;
    IAMMOracle public oracle;

    mapping(address => uint256) public collateralDeposits;

    constructor(IERC20 _collateral, IERC20 _loan, IAMMOracle _oracle) {
        collateralToken = _collateral;
        loanToken = _loan;
        oracle = _oracle;
    }

    function depositCollateral(uint256 amount) external {
        require(amount > 0, "invalid amount");
        collateralToken.transferFrom(msg.sender, address(this), amount);
        collateralDeposits[msg.sender] += amount;
    }

    function borrow(uint256 loanAmount) external {
        // ❌ Vulnerable: reads manipulable AMM spot price
        uint256 price = oracle.spotPrice(address(collateralToken));
        uint256 value = collateralDeposits[msg.sender] * price;

        require(value >= loanAmount, "Not enough collateral");
        loanToken.transfer(msg.sender, loanAmount);
    }
}
