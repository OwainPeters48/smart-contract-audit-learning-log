# About ERC20 and Weird Tokens

**What is ERC20?**
ERC20 tokens are the most widely used standard for fungible tokens on Ethereum.  It defines a basic interface that tokens must follow, including functions like `function`, `approve` `balanceOf`.
The goal was to make tokens work with any wallet, exchange, or protocol, as long as they implemented the same interface.  This simplicity is why almost every major token (USDT, USDC, DAI, etc) is built on ERC20.

**The Problem: ERC20 Isn't Strict**
The ERC20 specification is so loosely defined - mostly defining function signatures, but not strict behaviour - so that token developers often introduce "quirks" or outright violations of the expected semantics.
This inconsistency makes building smart contracts that interface directly with ERC20 tokens challenging, and caused major issues in DeFi protocols that assumed ERC20 tokens would behave predictably.  For example:
    - Missing return values: Some tokens don't return a boolean from `transfer()`, breaking integrations that require it.
    - Transfer fees: Some tokens deduct a fee on transfer, which can be exploited in AMMs and lending pools.
    - Upgradable tokens: Some stablecoins allowq admins to upgrade logic at any time introducing governance and censorship risks.

**Why It Matters**
For smart contract developers and auditors, EC20 quirks are a recurring source of integration bugs and vulnerabilities.  Billions of dollars in value flow through ERC20 tokens every day, and even small inconsistencies can lead to catastrophic losses.
To defend against this, auditors recommend:
    - Using wrapper libraries like OpenZeppelin's `SafeERC20`.
    - Avoiding assumptions (always check balance changes before/after transfers).
    - Where possible, allow listing known "safe" tokens.
    - Designing systems to fail gracefully when token behaviour is unexpected.