// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    What's fixed here?
    - Uses a trusted oracle (e.g., Chainlink or TWAP) instead of AMM spot price
    - Adds staleness check to reject outdated price data
    - Normalizes decimals to 1e18 for consistent valuation
    - Imposes conservative Loan-to-Value (LTV) ratio (70%) to reduce risk
    - Protocol logic no longer trusts easily manipulated liquidity pools
*/

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IPriceFeed {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function decimals() external view returns (uint8);
}

contract OracleManipulationFixed {
    IERC20 public collateralToken;
    IERC20 public loanToken;
    IPriceFeed public trustedOracle;

    mapping(address => uint256) public collateralDeposits;

    uint256 public constant MAX_STALE = 1 hours;   // reject prices older than 1h
    uint256 public constant LTV_BPS = 7000;        // 70% Loan-to-Value
    uint256 public constant BPS = 10_000;

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
        ( , int256 answer, , uint256 updatedAt, ) = trustedOracle.latestRoundData();
        require(answer > 0, "bad price");
        require(block.timestamp - updatedAt <= MAX_STALE, "stale price");

        uint8 dec = trustedOracle.decimals();
        uint256 px = uint256(answer);
        if (dec < 18) px *= 10**(18 - dec);
        else if (dec > 18) px /= 10**(dec - 18);

        uint256 collateralValue = collateralDeposits[msg.sender] * px / 1e18;
        uint256 maxBorrow = (collateralValue * LTV_BPS) / BPS;

        require(loanAmount <= maxBorrow, "Exceeds LTV");
        loanToken.transfer(msg.sender, loanAmount);
    }
}
