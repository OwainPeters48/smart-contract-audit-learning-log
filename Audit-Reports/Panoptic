### Panoptic – Low Severity Issue

1. It tracks liquidity in `s_poolAssets` so withdrawals subtract from it and reflect the true pool balance.  
2. The bug is in `CollateralTracker.sol` → `withdraw()` function.  
3. **Root cause:** Assets are subtracted from `s_poolAssets` in an unchecked block with no validation to ensure `s_poolAssets >= assets`.  
4. **Why it’s a problem:** If `s_poolAssets` is low, subtraction can underflow, wrapping to a huge value.  
5. **Fix:**  
        ```if (assets > s_poolAssets) revert Errors.ExceedsMaximumRedemption();```
6.  **Severity reasoning:** Classified Low because no funds can be stolen; only temporary disruption of withdrawal functionality.

When reading an audit, follow these 6 steps:
Purpose
Location
Cause
Impact
Fix
Severity Logic

🔗 Full Audit Report – Panoptic (Code4rena)
