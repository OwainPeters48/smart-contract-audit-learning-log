# SWC-107: Reentrancy Vulnerability – PoC & Fix

This repository demonstrates **SWC-107: Reentrancy** using a minimal vulnerable contract, an attacker contract to exploit it, and a fixed version.  
It includes:
- **VulnerableVault.sol** – intentionally unsafe
- **Attacker.sol** – exploits the vulnerability
- **FixedVault.sol** – secured with Checks-Effects-Interactions
- **Slither static analysis output** – automated detection of the bug

---

## 📂 Contracts

### 1. VulnerableVault.sol
- Records ETH balances per user.
- `withdraw()` sends ETH **before** setting balance to zero.
- This allows malicious contracts to re-enter and withdraw repeatedly.

### 2. Attacker.sol
- Deposits ETH into the vault.
- Calls `withdraw()` to trigger payout.
- Uses its `receive()` function to **re-enter** `withdraw()` before the vault updates state.

### 3. FixedVault.sol
- Follows **Checks-Effects-Interactions**:
  - Checks balance.
  - Sets balance to zero.
  - Sends ETH last.
- Prevents reentrancy by locking state before external calls.

---

## 🚨 Vulnerability

**Type:** Reentrancy (SWC-107)  
**Impact:** Allows attacker to drain vault’s ETH balance.  
**Cause:** External call to `msg.sender.call{value: amount}("")` before updating `balances[msg.sender]`.

---

## 🛠️ Proof of Concept (Remix)

1. **Deploy** `VulnerableVault`.
2. **Deploy** `Attacker` with vault’s address in constructor.
3. **Deposit** 5 ETH into `VulnerableVault` from an EOA.
4. **Attack** – Call `attack()` on `Attacker` with 1 ETH:
   - Attacker’s `receive()` re-enters vault until it’s drained.
5. **Observe** – Vault balance ≈ 0, attacker balance increased.
6. Repeat using `FixedVault` – attack fails.

---

## 🔍 Static Analysis – Slither

Slither output for `VulnerableVault.withdraw()`:
        Reentrancy in VulnerableVault.withdraw() (VulnerableVault.sol#10-16):
        External calls:
        - (ok,None) = msg.sender.call{value: amount}() (VulnerableVault.sol#13)
        State variables written after the call(s):
        - balances[msg.sender] = 0 (VulnerableVault.sol#15)
        VulnerableVault.balances (VulnerableVault.sol#4) can be used in cross function reentrancies:
        - VulnerableVault.balances (VulnerableVault.sol#4)
        - VulnerableVault.deposit() (VulnerableVault.sol#6-8)
        - VulnerableVault.withdraw() (VulnerableVault.sol#10-16)
        Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities
