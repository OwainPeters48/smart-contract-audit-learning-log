# Front-Running (Transaction Ordering Dependence)

**What is Front-Running?**
Front-running occurs when an attacker observes a pending transaction in the public mempool and submits their own transaction with higher gas fees to be mined first.  This allows them to profit from predictable state changes, often at the direct expense of the victim.  Its a form of MEV (Maximal Extractable Value).

**Why Front-Running Matters in Security**
- Guaranteed visibility - All pending txs are public in the mempool.
- Low effort, high reward - Bots can instantly copy and outbid user txs.
- Protocol-agnostic - Affects DEXs, NFTs, lending, governance, and more.
- MEV ecosystem - Sophisticated searches run bots 24/7 to exploit weak contracts.

**Common Exploits Enabled by Front-Running**
1.  DEX Arbitrage / Sandwich Attacks
    - Victim swaps a token in a low-liquidity pool.
    - Attacker front-runs by buying first -> pushes price up.
    - Victim's trade executes at a worse rate.
    - Attacker back-runs by selling into inflated price.
2.  NFT Mint Sniping
    - Victim submits NFT mint tx.
    - Attacker front-runs with higher gas, mints before them, and flips on secondary market.
3.  Liquidation Capture
    - Victim sees a position ready to liquidate.
    - Attacker copies liquidation tx with higher gas -> seizes collateral instead.
4.  Governance Manipulation
    - Victim submits a governance vote.
    - Attacker front-runs with an opposing vote or proposal execution.

**Key Risk Factors**
- Protocols that don't randomise or delay execution order.
- DEXes relying on AMM spot swaps without slippage protection.
- NFT contracts with unrestricted minting functions.
- Lending protocols where anyone can liquidate, but rewards aren't disigned to discourage bots.