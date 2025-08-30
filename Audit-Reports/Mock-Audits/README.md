# Mock Audits 🕵️‍♂️🔍

This repository contains my **mock security audits** of smart contracts.  
The purpose is to document my learning process as I practice professional audit workflows, build a portfolio, and contribute to the Web3 security community.  

> ⚠️ **Disclaimer**  
> These are **mock audits** performed for educational purposes only.  
> Findings may not represent exploitable vulnerabilities in production contracts.  
> Do not rely on these reports for live deployments.  

---

## 📂 Audit Reports

### 1. # Mock Audits 🕵️‍♂️🔍

This repository contains my **mock security audits** of smart contracts.  
The purpose is to document my learning process as I practice professional audit workflows, build a portfolio, and contribute to the Web3 security community.  

> ⚠️ **Disclaimer**  
> These are **mock audits** performed for educational purposes only.  
> Findings may not represent exploitable vulnerabilities in production contracts.  
> Do not rely on these reports for live deployments.  

---

## 📂 Audit Reports

### 1. [Mock Audit #1 – ERC20 Token (OpenZeppelin v4.x)]
- **Target:** ERC20.sol (OpenZeppelin)  
- **Findings:**  
  - Medium: ERC20 Approval Race Condition  
  - Informational: Inconsistent pragma directives  
- **Tools:** Slither Analyzer, Manual Review  
- **Status:** Completed (20 Aug 2025)  

---

### 2. [Mock Audit #2 – Lottery Contract (Solidity v0.4.17)]
- **Target:** Lottery.sol  
- **Findings:**  
  - High: Funds locked if manager inactive  
  - High: Weak randomness (predictable PRNG)  
  - Medium: State update after external call (CEI violation)  
  - Medium: Division by zero in `pickWinner()`  
  - Medium: No limit on entries per address (fairness issue)  
  - Medium: Unbounded players array (DoS risk)  
  - Low: Unrestricted ether contributions  
  - Informational: Player list disclosure via `getPlayers()`  
  - Informational: Outdated compiler pragma  
- **Tools:** Manual Review, Slither Analyzer  
- **Status:** Completed (24 Aug 2025)  

---

### 3. [Mock Audit #3 – NFT Marketplace (Custom Solidity v0.8.x)]
- **Target:** NFT.sol, Marketplace.sol  
- **Findings:**  
  - Medium: Denial of Service via `.transfer()` to malicious seller  
  - Medium: CEI violation in `createMarketplaceSale()` enables future reentrancy surface  
  - Low: Inefficient view functions (gas scalability concerns)  
  - Informational: Non-constant listing price   
- **Tools:** Slither, Manual Review, Custom Foundry Tests (DoS PoC)  
- **Status:** Completed (28 Aug 2025)

---

### 4. [Mock Audit #4 – PizzaDrop (Aptos Move Contract)]
- **Target:** pizza_drop::airdrop.move  
- **Findings:**  
  - Medium: Predictable randomness via `timestamp::now_microseconds()` (manipulable outcomes)  
  - Low: Missing `Funded` event in `fund_pizza_drop` (reduces transparency for off-chain monitoring)  
- **Tools:** Manual Review (Move), Custom Unit Tests  
- **Status:** Completed (30 Aug 2025)

---

## 🛠️ Methodology

Across all mock audits, I practice the following process:
- Scope & repo setup  
- Manual review of access control, state management, logic, external calls, and events  
- Static analysis with [Slither](https://github.com/crytic/slither)  
- Documentation of findings with severity, PoCs, and recommendations

---

## 📬 Contact

- **X (Twitter):** [@0xOwain](https://x.com/0xOwain)  
- **GitHub:** [OwainPeters48](https://github.com/OwainPeters48)  

---

More audits coming soon 🚀

