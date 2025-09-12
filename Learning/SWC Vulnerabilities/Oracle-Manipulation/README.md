# Oracle Manipulation

**What is Oracle Manipulation?**
An oracle provides external data (like token prices) to a smart contract.  if a protocol relies on a weak or manipulable oracle, attackers can distort it and drain value.  This often happens when protocols read spot prices from Automated Market Makers (AMMs) like Uniswap or SushiSwap without safeguards.

**Why Oracle Manipulation Matters in Security**
- Easy to manipulate - Low-liquidity pools can be shifted with a single large trade.
- Composability Risks - One manipulated pool can affect multiple protocols relying on it.
- Flash Loan Synergy - Attackers don't need capital; they can borrow millions instantly to distort oracles.

**Common Exploits Enabled by Oracle Manipulation**
1.  Colatteral Inflation
    Attackers pump the price of their collateral via an AMM, deposit it into a lending protocol, and borrow stablecoins against the inflated value.
        - Protocol is left with worthless collateral.
        - Case Study: bZx Protocol (2020) - multiple oracle manipulation attacks, #$8M lost.

2.  Liquididation Abuse
    Attackers push the price of another user's collateral down temporarily.
        - This triggers liquidation at an artificially cheap price.
        - Attacker buys discounted collateral and profits.

3.  Cross-Protocol Arbitrage
    Manipulated pool price feeds into another protocol.
        - Exploits differences in valuation across DeFi apps.
        - Case Study: Mango Markets (2022) - manipulated MNGO token price to drain #$114M.

4.  Stablecoin Drains
    If stablecoins rely on AMM pools for peg checks, an attacker can shift the pool to unpeg the coin and drain collateral reserves.

**Key Risk Factors**
- Reliance on AMM spot prices.
- No time-weighted averaging (TWAP) or Chainlink integration.
- Missing sanity checks (e.g., rejecting > 20% price swings per block).
- 100% Loan-to-Value thresholds with no buffer.

**Mitigations**
- use robust oracles (chainlink, TWAPs).
- Add sanity bounds on price movement.
- Introduce conservative LTV ratios (e.g., 70%).
- Apply timelocks or mutiple feeds for governance-related prices.
- Circuit breakers that pause activity if volatility is abnormal.