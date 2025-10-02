# Fallback Playground — demo of `fallback()` / `receive()` pitfalls

A small Foundry playground that demonstrates common pitfalls when sending ETH to external addresses (push-in-loop vs pull-payments), and how a malicious recipient’s `fallback`/`receive` can block or break your contract.

This repo contains short, focused examples and tests so you can *see* the problem and the fix in a minimal, reproducible way.

---

## What’s included

- **`src/Victim.sol`** — vulnerable push-in-loop payout: iterates over `payees` and `transfer(1 ether)` to each. A single malicious contract address can block the whole payout.  
- **`src/VictimFixed.sol`** — fixed: credits balances and uses a `withdraw()` pull pattern (checks → effects → interactions).  
- **`src/Attacker.sol`** — attacker contract whose `fallback()` always reverts (demonstrates DoS-by-revert).  
- **`test/DoSWithFallback.t.sol`** — Foundry tests that:
  - show the vulnerable contract is DoS’d by the attacker, and
  - show the fixed contract allows honest users to withdraw while the attacker’s own withdraw fails (does not block others).

---

## Why this matters

When your contract sends ETH to an address that is a contract, the EVM executes the recipient’s code (`receive()` or `fallback()`). The recipient can:

- revert (block your call),
- consume gas (make low-gas transfers fail), or
- re-enter (if you aren’t careful).

Push-in-loop patterns (calling many external addresses inside a loop) are fragile — an attacker in the list can make the whole transaction fail. The standard mitigation is **pull payments**: record balances and let recipients call `withdraw()` themselves.

---

## Quick start (run tests)

You need [Foundry](https://book.getfoundry.sh/) installed.

From project root:

```bash
# clean previous builds
forge clean

# run tests with verbose output
forge test -vvv
```

You should see tests pass for the examples in `test/DoSWithFallback.t.sol`. The tests demonstrate the DoS and the fix.

## Files / Structure
    src/
     Attacker.sol        # attacker contract (fallback reverts)
     Victim.sol          # vulnerable push-in-loop
     VictimFixed.sol     # pull-payments fix

    test/
     DoSWithFallback.t.sol  # Foundry tests demonstrating exploit & fix

## What to look for in the tests
- `testDoS_RevertsOnPushLoop`
    Calls `Victim.payAll()`. Because the attacker reverts inside its fallback, the whole `payAll()` reverts — nobody gets paid. This is the DoS-by-recipient example.

- `testPullWithdraw_OnlyAttackerFails`
    Shows that with the pull pattern (`VictimFixed`): honest users (Alice, Bob) can `withdraw()` successfully. The attacker’s own `withdraw()` fails, but it does not block others.

Note: low-level `.call{value: ...}("")` returns `(bool, bytes)`. We `require(ok, "withdraw failed")`. That masks the attacker’s revert reason; tests expect `"withdraw failed"`.