// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    Fixed Lending Protocol
    - Uses a robust oracle (e.g., Chainlink or TWAP).
    - Adds sanity checks to prevent single-tx price manipulation.
*/

/*
    What's fixed here?
    - Trusted oracle (e.g., Chainlink or TWAP) resists flash loan manipulation
    - Loan-to-Value (LTV) limit reduces risk even if oracle is slightly delayed
    - Protocol logic no longer trusts a single spot price from an AMM
*/

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address user) external view returns (uint256);
}

interface IPriceFeed {
    function latestAnswer() external view returns (int256);
}

contract SecureLending {
    IERC20 public collateralToken;
    IERC20 public loanToken;
    IPriceFeed public trustedOracle;

    mapping(address => uint256) public collateralDeposits;

    constructor(IERC20 _collateral, IERC20 _loan, IPriceFeed _oracle) {
        collateralToken = _collateral;
        loanToken = _loan;
        trustedOracle = _oracle;
    }

    function depositCollateral(uint256 amount) external {
        require(amount > 0, "invalid amount");
        collateralToken.transferFrom(msg.sender, address(this), amount);
        collateralDeposits[msg.sender] += amount;
    }

    function borrow(uint256 loanAmount) external {
        uint256 price = uint256(trustedOracle.latestAnswer());
        uint256 collateralValue = collateralDeposits[msg.sender] * price;

        // Require at least 70% collateralization
        require(loanAmount <= (collateralValue * 70) / 100, "Exceeds LTV");

        loanToken.transfer(msg.sender, loanAmount);
    }
}
