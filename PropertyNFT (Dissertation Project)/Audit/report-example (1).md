---
title: Property NFT Marketplace Audit Report
author: 0xOwain
date: 
header-includes:
  - \usepackage{titling}
  - \usepackage{graphicx}
---

\begin{titlepage}
    \centering
    \begin{figure}[h]
        \centering
        \includegraphics[width=0.5\textwidth]{logo.pdf} 
    \end{figure}
    \vspace*{2cm}
    {\Huge\bfseries Property NFT Marketplace Audit Report\par}
    \vspace{1cm}
    {\Large Version 1.0\par}
    \vspace{2cm}
    {\Large\itshape 0xOwain\par}
    \vfill
    {\large \today\par}
\end{titlepage}

\maketitle

<!-- Your report starts here! -->

Prepared by: [0xOwain](https://Github.com/Owainpeters48)(https://x.com/0xOwain)

Lead Auditors: 
- 0xOwain

# Table of Contents
- [Table of Contents](#table-of-contents)
- [Protocol Summary](#protocol-summary)
- [Disclaimer](#disclaimer)
- [Risk Classification](#risk-classification)
- [Audit Details](#audit-details)
  - [Scope](#scope)
  - [Roles](#roles)
- [Executive Summary](#executive-summary)
  - [Issues found](#issues-found)
- [Findings](#findings)
- [High](#high)
- [Medium](#medium)
- [Low](#low)
- [Informational](#informational)
- [Gas](#gas)

# Protocol Summary

PropertyNFT Protocol
The PropertyNFT project is a smart contract system for blockchain-based property transactions. It uses ERC-721 NFTs to represent unique properties on-chain, with metadata stored on IPFS.

Key features:
- PropertyNFT.sol – core ERC-721 contract for minting, listing, and transferring property tokens.
- CreateLibrary.sol – manages transaction logs, maintenance records, and compliance updates.
- GetterLibrary.sol – view functions to retrieve property data, ownership history, and transaction logs.
- AnalyticsLibrary.sol – provides analytics such as total sales volume, average property value, and other derived metrics.

Intended use cases:
- Minting new property NFTs tied to off-chain property records.
- Secure listing and transfer of property ownership on-chain.
- Transparent compliance + maintenance recordkeeping.
- On-chain analytics for property markets.

Assets at risk: property NFTs, ETH/ERC20 payments in transactions, and trust in metadata integrity.

# Disclaimer

The 0xOwain team makes all effort to find as many vulnerabilities in the code in the given time period, but holds no responsibilities for the findings provided in this document. A security audit by the team is not an endorsement of the underlying business or product. The audit was time-boxed and the review of the code was solely on the security aspects of the Solidity implementation of the contracts.

# Risk Classification

|            |        | Impact |        |     |
| ---------- | ------ | ------ | ------ | --- |
|            |        | High   | Medium | Low |
|            | High   | H      | H/M    | M   |
| Likelihood | Medium | H/M    | M      | M/L |
|            | Low    | M      | M/L    | L   |

We use the [CodeHawks](https://docs.codehawks.com/hawks-auditors/how-to-evaluate-a-finding-severity) severity matrix to determine severity. See the documentation for more details.

# Audit Details 

## Scope 

**In Scope**
- `PropertyNFT.sol`
- `CreateLibrary.sol`
- `GetterLibrary.sol`
- `AnalyticsLibrary.sol`

**Commit Hash** 943caa73e500c230f408316b549bdd3816beb553

**cloc**
---------------------------------------------------------------------------------
File                                          blank        comment           code
---------------------------------------------------------------------------------
contracts/PropertyNFT.sol                       110              1            349
contracts/GetterLibrary.sol                      11              1             48
contracts/AnalyticsLibrary.sol                    4              1             37
contracts/CreateLibrary.sol                       5              1             34
---------------------------------------------------------------------------------
SUM:                                            130              4            468
---------------------------------------------------------------------------------




## Roles
🔐 Roles and Permissions

The PropertyNFT contract uses OpenZeppelin's AccessControl
 to define and manage granular role-based access. The following roles are defined:

🔸 `DEFAULT_ADMIN_ROLE`
- Granted to: Deployer (`msg.sender` in constructor)
- Privileges:
  - Can grant and revoke all other roles.
  - Has full control over contract-level configuration.
  - Can call:
    - `setMaxTotalSupply` (if implemented)
    - Any internal `_canSet*` functions inherited via base contracts
    - Likely also governs platform fees, royalty config, contract metadata, etc. (via inherited OpenZeppelin & internal modules)

🔸 `ADMIN_ROLE`
- Granted to: Deployer by default
- Privileges:
  - Core protocol management, including minting, approval, and compliance.
  - Can call:
    - `updateCompliance(...)` – update checklist booleans + inspector notes
    - `approveProperty(...)` – approve pending properties after compliance pass
    - `rejectProperty(...)` – reject pending properties
    - `burn(...)` – burn NFTs
    - `updatePropertyDetails(...)` – update metadata fields on-chain
    - `recordTransaction(...)` – log transaction + analytics
    - `addRequriedComplianceType(...)` – add new compliance check types

🔸 `COMPLIANCE_ROLE`
- Granted to: Deployer by default
- Privileges:
  - Currently unused in the provided contract, though reserved in the constructor with:
    `_grantRole(COMPLIANCE_ROLE, msg.sender);`


Possible future purpose:
- Manage compliance validations
- Issue expiry dates
- Trigger compliance-related events
- Considered a placeholder or future role, with no active function calls requiring it in current logic.

🧾 Notes:

All `onlyRole(...)` checks are implemented correctly using `AccessControl`.
- `Ownable` is also used via `Ownable.sol` – the constructor sets the deployer as owner.
- However, `Ownable` functions like `onlyOwner` aren’t actively used in the contract’s custom logic, only inherited.
- Role administration (e.g., `grantRole`, `revokeRole`) is left up to the `DEFAULT_ADMIN_ROLE` holder (deployer unless changed).

# Executive Summary
## Issues found
# Findings
# High
# Medium
# Low 
# Informational
# Gas 