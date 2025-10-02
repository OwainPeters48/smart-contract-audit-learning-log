# Smart Contract Vulnerability Playgrounds

This folder contains a collection of small, focused Foundry projects (“playgrounds”) that demonstrate common smart contract vulnerabilities and their mitigations.  

Each playground is a self-contained repo with:  
- Minimal vulnerable contracts  
- Attacker contracts  
- Fixed versions  
- Foundry tests that reproduce the exploit and show the mitigation working  

The goal: build hands-on intuition for how exploits work and how to defend against them.  

---

## 📂 Contents

### 1. [Reentrancy Playground](./reentrancy-playground)
- **What it covers:** 10+ reentrancy patterns (`call`, `transfer`, `send`, external function calls, modifiers, etc.)  
- **What you’ll find:** vulnerable functions, attacker contracts, and fixed versions (mutex, CEI, pull pattern).  
- **Tests:** Foundry PoCs showing how each reentrancy exploit works and how the mitigation stops it.  

### 2. [Fallback Playground](./fallback-playground)
- **What it covers:** dangers of `fallback()` / `receive()` (DoS by revert, gas griefing, unexpected ether).  
- **What you’ll find:** 
  - `Victim.sol` — naive push-in-loop payouts  
  - `Attacker.sol` — malicious contract with reverting fallback  
  - `VictimFixed.sol` — pull-payment fix  
- **Tests:** Foundry PoCs demonstrating how a single malicious payee can block everyone, and how the pull pattern fixes it.  

---

## 🔧 How to run

You need [Foundry](https://book.getfoundry.sh/) installed.

From inside any playground (e.g. `fallback-playground/`):

```bash
forge install
forge build
forge test -vvv
```