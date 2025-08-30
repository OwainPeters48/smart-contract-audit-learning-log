# Cyfrin Updraft Audit Reports  

This folder contains my progress and reports from working through the **Cyfrin Updraft smart contract auditing course**.  
The goal is to build real audit experience by reviewing example contracts, writing structured reports, and documenting findings as I learn.  

---

## 📂 Contents  

### 1. PasswordStore Audit Report (Module 3)  
- **Target:** PasswordStore.sol  
- **Focus:** Introductory audit exercise covering storage, access control, and basic security checks.  
- **Includes:**  
  - Scope and protocol summary  
  - Risk classification  
  - High- and low-severity findings  
  - Proof of concept tests written in Foundry  
  - Recommendations for mitigation  
- 📄 [Full Audit Here](./PasswordStoreAudit.pdf)  

---

### 2. PuppyRaffle Audit Report (Module 4)  
- **Target:** PuppyRaffle.sol  
- **Focus:** Larger guided audit exercise covering CEI, randomness, integer safety, and denial-of-service risks.  
- **Findings Summary:**  
  - High: Reentrancy in `refund`  
  - High: Weak randomness in `selectWinner`  
  - High: Integer overflow in `totalFees`  
  - Medium: DoS/gas scaling from duplicate checks  
  - Low: Ambiguous return in `getActivePlayerIndex`  
  - Informational/Gas: pragma versioning, CEI consistency, avoiding magic numbers  
- 📄 [Full Audit Here](./PuppyRaffleAudit.pdf)  

---

## 🧑‍💻 About Me  

I’m **Owain Peters (aka 0xOwain)**, a Computer Science graduate (Swansea University, 2:1) and aspiring Web3 smart contract auditor.  
This repository tracks my journey to becoming a professional auditor, starting with learning resources like Cyfrin Updraft and expanding into mock and real audits.  

---

## ⚠️ Disclaimer  

These reports are written as part of my **learning process**.  
They do not represent professional audits and should **not** be relied on for production code.  
