# Flash Loan

**What is a Flash Loan?**
A flash loan is an uncollateralised loan where a user can borrow any amount of tokens as long as the debt is repaid within the same transaction.  If repayment fails, the whole transaction reverts - meaning the lender faces no risk.
Flash loans were introduced by Aave and have since become a standard primitive in DeFi.  While they are powerful tools for arbitrage and liquidations, they also give attackers instant access to massive capital, enabling exploits that would otherwise be impossible.

**Why Flash Loans Matter in Security**
- Capital Amplifier - Attackers dont need upfront funds, they can borrow millions instantly.
- One-Transaction Atomicity - Exploit chains can be executed in a single transaction, making detection harder.
- Legitimate Uses Exist - Flash loans are not inherently bad (arbitrage, debt, refinancing, liquidations) but poor smart contract design makes them exploitable.

**Common Exploits Enabled by Flash Loans**
1.  Price Oracle Manipulation
    Attackers can use flash loans to manipul;ate low-liquidity pools (e.g., Uniswap, SushiSwap) that serve as on-chain price oracles.
        - Inflate/deflate token price within a single block.
        - Trigger undercollateralized borrowing or liquidations at fake prices.
        - Case Study: Harvest Finance (2020) - attacker manipulated Curve pools to drain #$34M.

2.  AMM & Liquidity Pool Exploits
    Automated Market Makers (AMMs) rely on invariant formulas (`x * y = k`).  Large temporary trades can shift the pool state drastically.
        - Drain pool reserves via slippage.
        - Force mispriced swaps into other protocols.
        - Case Study: PancakeBunny (2021) - flash loaned BNB to manipulate BUNNY/BNB pool, minted BUNNY cheaply, dumped it #$45M stolen.

3.  Governance Attacks
    If voting power is based onb token balances at a snapshot within the same block, attackers can borrow voting tokens, pass malicious proposals, and return them instantly.  
        - Manipulate protocol upgrades.
        - Drain treasuries via governance proposals.
        - Case Study: Beanstalk (2022) - #$182M governance attack executed with a flash loan.

4.  Collateral & Lending Protocol Exploits
    Lending systems that accept collateral can be exploited if collateral valuation relies on manipulable oracles.
        - Flash loan to pump price of collateral.
        - Borrow against inflated collateral.
        - Dumb collateral after repayment.
        - Case Study: bZx Protocol (20200) - multiple flash loan attacks exploiting oracle dependencies, #$8M lost over time.

5.  Cross-Protocol Arbitrage Abuse
    Attackers chain multiple protocols together within the loan window to extract risk-free profits or trigger inconsistencies.
        - Exploit differences in AMM pricing and lending logic.
        - Combine with reentrancy for layered attacks.

**Key Risk Factors**
- Reliance on manipulable AMMs as oracles.
- Protocols that dont account for single-transaction atomic manipulations.
- Governance systems without timelocks or snapshot mechanisms.
- Complex multi-protocol integrations with no invariant checks.

**Mitigations**
- Use robust oracles (e.g., Chainlink, TWAPs).
- Add timelocks to governance to prevent instant execution.
- Validate invariants (e.g., collateralisation ratios) after external calls.
- Circuit breakers for abnormal liquidity ranges.
- Monitor flash loan usage for anomaly detection.

/*
    What goes wrong?
    - Attacker flash loans a large amount of collateral
    - Pushes up the AMM spot price by swapping aggressively
    - Calls `borrow()`, which uses teh inflated oracle price
    - Borrows way more `loanToken` than their collateral is really worth
    - Repays the flash loan, keeps the excess profit
*/