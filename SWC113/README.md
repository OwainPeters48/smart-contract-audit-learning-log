# Slither Analysis – SWC113_vulnerable.sol

**Contract:** RefundAll_DoS  
**Solidity version:** ^0.8.22  
**Tool:** Slither  

## Key Findings
- ❌ **Denial of Service**: `refundAll()` loops over recipients and sends ETH. Any revert blocks the loop.  
- ❌ **Reentrancy Risk**: State update (`refunds[to] = 0`) happens *after* external call.  
- ❌ **Low-Level Call**: `address(to).call` is dangerous; no gas stipend and no error handling.  
- ⚠️ **Style/Optimization**: Contract not in CapWords, array length not cached.  

## References
- [SWC-113: DoS with (Unexpected) Revert](https://swcregistry.io/docs/SWC-113)  

## Raw Output
INFO:Detectors:
RefundAll_DoS.refundAll() (SWC113_vulnerable.sol#17-28) sends eth to arbitrary user
        Dangerous calls:
        - (ok,None) = address(to).call{value: amt}() (SWC113_vulnerable.sol#24)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#functions-that-send-ether-to-arbitrary-destinations
INFO:Detectors:
Reentrancy in RefundAll_DoS.refundAll() (SWC113_vulnerable.sol#17-28):
        External calls:
        - (ok,None) = address(to).call{value: amt}() (SWC113_vulnerable.sol#24)
        State variables written after the call(s):
        - refunds[to] = 0 (SWC113_vulnerable.sol#26)
        RefundAll_DoS.refunds (SWC113_vulnerable.sol#5) can be used in cross function reentrancies:
        - RefundAll_DoS.refundAll() (SWC113_vulnerable.sol#17-28)
        - RefundAll_DoS.refunds (SWC113_vulnerable.sol#5)
        - RefundAll_DoS.seed(address[],uint256) (SWC113_vulnerable.sol#8-14)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities
INFO:Detectors:
RefundAll_DoS.refundAll() (SWC113_vulnerable.sol#17-28) has external calls inside a loop: (ok,None) = address(to).call{value: amt}() (SWC113_vulnerable.sol#24)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation/#calls-inside-a-loop
INFO:Detectors:
Version constraint ^0.8.22 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
        - VerbatimInvalidDeduplication.
It is used by:
        - ^0.8.22 (SWC113_vulnerable.sol#2)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity
INFO:Detectors:
Low level call in RefundAll_DoS.refundAll() (SWC113_vulnerable.sol#17-28):
        - (ok,None) = address(to).call{value: amt}() (SWC113_vulnerable.sol#24)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls
INFO:Detectors:
Contract RefundAll_DoS (SWC113_vulnerable.sol#4-31) is not in CapWords
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
INFO:Detectors:
Loop condition i < recipients.length (SWC113_vulnerable.sol#18) should use cached array length instead of referencing `length` member of the storage array.
 Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#cache-array-length
INFO:Slither:.\SWC113_vulnerable.sol analyzed (1 contracts with 100 detectors), 7 result(s) found
