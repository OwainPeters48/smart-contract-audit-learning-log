Slither Analysis – SWC112_vulnerable.sol  
Contract: DelegateCallBad  
Solidity version: ^0.8.24  
Tool: Slither  

---

### Key Findings  
❌ **Delegatecall to Untrusted Callee**: `delegatecall` accepts user-controlled address (`callee`).  
❌ **Storage Hijacking**: Untrusted delegatecall allows attacker to overwrite critical storage (e.g. `owner`).  
❌ **Lack of Access Control**: `execute()` is publicly accessible with no checks.  
⚠️ **Missing Input Validation**: No restriction on `callee`, allowing arbitrary logic execution.

---

### References  
SWC-112: https://swcregistry.io/docs/SWC-112  
Slither Delegatecall Detector: https://github.com/crytic/slither/wiki/Detector-Documentation#delegatecall-to-user-controlled-address

---

### Raw Output  
INFO:Detectors:
DelegateCallBad.execute(address,bytes) (delegatecallBad.sol#15-19) uses delegatecall to a input-controlled function id
        - (success,None) = callee.delegatecall(data) (delegatecallBad.sol#17)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#controlled-delegatecall
INFO:Detectors:
DelegateCallBad.execute(address,bytes).callee (delegatecallBad.sol#15) lacks a zero-check on :
                - (success,None) = callee.delegatecall(data) (delegatecallBad.sol#17)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation
INFO:Detectors:
Version constraint 0.8.22 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
        - VerbatimInvalidDeduplication.
It is used by:
        - 0.8.22 (delegatecallBad.sol#2)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity
INFO:Detectors:
Low level call in DelegateCallBad.execute(address,bytes) (delegatecallBad.sol#15-19):
        - (success,None) = callee.delegatecall(data) (delegatecallBad.sol#17)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls
INFO:Detectors:
DelegateCallBad.owner (delegatecallBad.sol#8) should be immutable
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#state-variables-that-could-be-declared-immutable
INFO:Slither:delegatecallBad.sol analyzed (1 contracts with 100 detectors), 5 result(s) found

---

### Summary  
This contract contains a high-severity vulnerability: a **user-supplied delegatecall**, which can be exploited to overwrite contract state, including `owner`, balances, or disable functionality.  
Fixes include:
- Restricting the target to a **trusted address**
- Adding a **zero address check**
- Moving to a **more recent compiler version**
- Marking `owner` as `immutable` if it doesn’t change post-deploy
