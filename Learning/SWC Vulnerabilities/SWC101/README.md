# SWC-101: Integer Overflow and Underflow

## Summary
When the integer reaches the maximum or minimum size of a type, an arithmetic operation can produce a value outside the range representable with that type’s bits.  
In Solidity < 0.8.0, this causes **wraparound** instead of reverting.

**Examples:**
- **Underflow:** `0 - 1` in `uint8` wraps to `255`.
- **Overflow:** `255 + 1` in `uint8` wraps to `0`.
- **Token accounting bug:** Subtracting from zero balance wraps to a huge `uint256`, creating “free” tokens.

---

## Notes / Examples

**Trigger Points**
- Any arithmetic (`+`, `-`, `*`, `/`) on unchecked or user-controlled input.

**Common Patterns**
- Small integer types (`uint8`, `uint16`).
- Subtraction in token transfers without balance check.
- Incrementing counters without bounds checks.

**Impact**
- Logic bypass.
- Creation of fake balances.
- Possible denial of service by manipulating state.

**Fix Strategies**
- Compile with Solidity ≥ 0.8.0 (automatic overflow/underflow checks).
- Use explicit `require` bounds checks.
- Only use `unchecked` when safety is guaranteed.

---

## References
- [SWC Registry – SWC-101](https://swcregistry.io/docs/SWC-101)
