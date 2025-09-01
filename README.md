# Smart Contract Audit — Learning Log

Public log of my journey into Web3 security. This repo includes:
- Vulnerable + fixed code for key SWC vulnerabilities
- Custom token edge cases (e.g. weird ERC20s, fuzz testing)
- Mock audits I’ve written from scratch
- Coursework (Property NFT platform + Cyfrin Updraft)

## Structure

### `/Audit-Reports/Mock-Audits/`
Self-run mock audits with real issues, proofs of concept, and fixes — training for freelance smart contract auditing.

### `/Audit-Reviews/`
Rewritten notes from professional audits (e.g. Code4rena Blackhole, Panoptic) to practice formal reporting tone and structure.

### `/Learning/`
Experimental area for hands-on testing:
- `/Fuzzing/` — Fuzz tests for contracts with odd edge cases (e.g. no return values, fee logic)
- `/SWC Vulnerabilities/` — Vulnerable + fixed contract pairs across major SWC IDs
- `/Weird-ERC/` — Tokens with broken, non-standard or surprising behaviours

### `/PropertyNFT (Dissertation Project)/`
University final-year project using Solidity + React: tokenised property ownership with compliance, metadata, and transfer logic.

### `/Cyfrin Updraft/`
Progress through Cyfrin’s Updraft smart contract security course — code + notes per module.

---

## Author

**0xOwain (Owain Peters)**  
[GitHub](https://github.com/OwainPeters48) — Learning smart contract auditing every day.
