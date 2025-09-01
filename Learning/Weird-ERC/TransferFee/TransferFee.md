# Fee-On-Transfer Tokens

## What's Weird?
Some ERC-20-like tokens deduct a fee from each transfer.  If you send `amount`, the receiver actually gets `amount - fee` (fee can be a percentage or a fixed amount).  Others don't charge a fee todau but can enable one later via admin settings.

## Why dangerous?
Protocols that assume `credited == amount` can be exploited or mis-account funcds.  Classic example: Balancer pools drained (~$500k) through STA's fee mechanics.  
Any system that:
    - Credits deposits using the user-provided amount (instead of actual received)
    - Relies on invariant mth that assumes conservation of tokens
    - Performs internal accounting without checking post-transfer balances
... can be griefed, drained, or bricked.

## Mitigation:
- Always measure balances before/after to comute the actual received amount:
```solidity
    uint256 balBefore = token.balanceOf(address(this));
    token.safeTransferFrom(msg.sender, address(this), amount);
    uint256 received = token.blanceOf(address(this)) - balBefore;
    require(received > 0, "zero-received");
    // credit `received`, not `amount`
```

- Use SafeERC20 wrappers for transfer safety; dont assume return values or 1:1 amounts.
- Price/Slippage checks: In AMMs, use minOut/maxIn guards and account for fee-on-transfer tokens explicitly.
- Adapt your accounting: Vaults should mint shares based on received, not on requested.
- Document token support: Where practical, allowlist tokens or expose a kill-switch for misbehaving assets.

## Key Takeaways for Audits
- Look for places where the code credits `amount` immediately after a transfer.
- Ensure real received tokens power the accounting (Deposits, shares, LP tokens).
- AMM math and lending/vault flows must be fee-aware (or explicitly forbid fee tokens).