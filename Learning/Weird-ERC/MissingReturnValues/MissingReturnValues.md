# Missing Return Values

## Whats Weird?
Siome ERC20 tokens (like USDT, BNB, OMG) do not return a `bool` for `transfer`, `approve`, or `transferFrom`.  Others (e.g., Tether Gold) declare a return value but always return false - even if the transfer succeeded.
This behaviour still compiles, but it breaks the assumpotinos that most protocols make.

## Why is this dangerous?
Protocols typically expect:
```solidity
    require(token.transfer(to, amount), "TRANSFER_FAILED");
```
But if `transfer` doesn't return a `bool`:
    - The call reverts during decoding, or
    - It returns empty data -> interpreted as `false`.
This has led to:
    - Stuck tokens in Uniswap v1 (BNB integration issue).
    - Unexpected reverts in vaults or AMMs.
    - Silent accounting errors if the return value is ignored.

## Mitigation
- ALways use wrappers like OpenZeppelin's SafeERC20, which tolerate both missing and false returns:
```solidity
    SafeERC20.safeTransfer(token, to, amount);
```

- When security-critical, also verify balance deltas:
```solidity
    uint256 before = token.balanceOf(address(this));
    token.safeTransferFrom(msg.sender, address(this), amount);
    uint256 received = token.balanceOf(address(this)) - before;
    reqwuire(received == amount, "BAD_AMOUNT_RECEIVED");
```

- Where possible, restrict integrations to an allowlist of known-safe tokens.

## Key Takeaways for Audits
- Never asume ERC-20 returns `bool`: Many tokens return no data or `false` on success.  Treat the return value as optional.
- Enforce SafeERC20 everywhere: All external token interactions should use a wrapper that tolerates missing/false returns or an equivalent low-level call check.
- Flag any `require(token.transfer(...))` / `require(token.approve(...))` uses that decode a `bool`.  Replace with safe wrappers.
