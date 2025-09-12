# Fuzzing

Fuzzing is hammering functions with many randomised inputs to surface crashes or violations of properties that should always hold.

## Why Fuzzing
Unit tests prove "this input works".
Fuzzing tries to prove "no input breaks this property".

Use fuzzing when:
    - There are many edge cases (ERC20 quirks, rounding, upgrades).
    - You can write properties/invariants (e.g., "conservation of value").
    - You want cheap breadth before deep manual review.
    Not a replacement for unit tests.  It's a property-finder and invariant-breaker.

## Core Concepts
Property: A true/false rule about outputs for a single call.
    Example: `receiver_gain == amount - fee(amount)`.
Invariant: A rule that remains true across sequences of calls / over time.
    Example: "Sum of balances equals `totalSupply` (minus burned fees)".
Preconditions: Constraints to avoid meaningless cases (e.g., `to != 0`, ,amount <= balance).  Use `vm.assume(...)` OR `Bound(...)`.
Oracle: The assertion that decids pass/fail (e.g., `assertEq(...)`).
Shrinking: When Foundry finds a failing input, it minimises it to a small repro case.

