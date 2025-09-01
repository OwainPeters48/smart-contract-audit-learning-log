# SWC-110: Assert Violation

**Summary:**  
Using `assert()` for input or user-triggered errors results in low-level panics (0x01), which are uninformative and unnecessary. `assert` is only for **invariants** and **internal logic assumptions**.

**Risk:** Low  
**Impact:** Poor debugging, unnecessary reverts  
**Severity if misused in invariants:** Medium–High

---

## ✅ Fix

Use `require()` for anything user-triggered or externally controllable:
```solidity
require(totalMinted + amount <= MAX_SUPPLY, "Exceeds max supply");
