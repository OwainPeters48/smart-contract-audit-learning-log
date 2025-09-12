# SWC-128 - Gas Griefing (DoS)

**What is Gas Griefing?**
Gas griefing occurs when a function performs work proportional to unbounded on-chain data (like iterating over a dynam,ic array).  An attacker can inflate this data until no transaction can provide enough gas to complete within the block gas limit.  This permanently disables critical functionality (like distributing rewards or upgrading the contract).

**Why Gas Griefing Matters in Security**
- Permanent DoS - A single function (often core logic like payout, migration, or liquidation) can be bricked forever.
- Cheap to exploit - Attackers can spam entries or inflate state cheaply, forcing other users to pay extreme gas costs or making the function uncallable
- Funds locked - Protocols that depend on loops for reward distribution or withdrawals risk leaving user funds stranded.
- Systemic fragility - Protocol upgrades or emergency recovery can fail if implemented via unbounded loops.

**Common Exploits Enabled by Gas Griefing**
1.  Reward Distribution Locks
    Protocol loops through all stakers to distribute rewards.
        - Attacker bloats staker list with Sybil accounts.
        - Distribution function exceeds block gas limit -> no rewards ever sent.
2.  Migration/Upgrade Freezes
    Contracts that migrate state by looping over users/orders.
        - Too many entries -> migration impossible without a fork.
3.  Batch Liquidation DoS
    Lending protocol liquidates borrowers in one loop.
        - Large number of accounts makes liquidation tx revert
        - Collateral stays undercollateralized.
4.  Cleanup Failures
    Admins try to "reset" state by deleting large arrays in a loop.
        - Array too large -> tx cannot complete.

**Key Risk Factors**
- Unbounded loops in state-changing functions.
- Push-based payments to multiple users in one transaction.
- Functions that rely on iterating over all users/orders.
- Protocols without pagination or pull-based designs.

**Mitigations**
- Pull payments: Let each user withdraw their own funds (O(1) operations).
- Pagination: Process a fixed number of entries per call (bounded gas cost).
- merkle proofs / off-chain accounting: Store a root on-chain, let users prove claims individually.
- Circuit breakers: Allow emergency admin escape (e.g., draining without looping).
- Testing under scale: Simulate 10k+ users in fuzz tests to surface loop risks.