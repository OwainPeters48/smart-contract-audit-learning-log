# PoC: Oracle manipulation in PriceOracleTarget

## Summary
Attacker controls a naive price feed and manipulates price between deposit & withdraw to withdraw far more ETH than deposited.

This playground demonstrates:
- Vulnerable contract: PriceOracleTarget (vulnerable)
- Fixed contract: PriceOracleTarget_fixed (safe)

## Preconditions
- Attacker can change oracle price (FakeOracle.setPrice is public in this playground).
- Target contract holds sufficient ETH to pay exploit (simulated in tests).

## Steps to reproduce (vulnerable)
1. Deploy FakeOracle with initial price 1.
2. Deploy PriceOracleTarget pointing to FakeOracle.
3. Fund PriceOracleTarget with ETH (e.g., 1000 ETH).
4. Attacker sets price to 1000.
5. Attacker deposits 1 ETH -> recorded usdBalance = 1000.
6. Attacker sets price to 1.
7. Attacker calls `withdraw()` -> receives 1000 ETH (in this playground).

## Impact
Funds can be drained if oracle is manipulable. Using current price for withdraws after deposit-time recording is unsafe.

## Fix / Recommendations
- Prefer storing ETH balances directly (see PriceOracleTarget_fixed).
- If USD accounting required, lock deposit-time price per deposit OR use robust signed aggregator + TWAP + sanity checks.
- Add access control to oracle updates / use trusted aggregator.

## Run
```bash
forge test --match-contract OraclePoC -vv
forge test --match-contract OracleFixedTest -vv
```