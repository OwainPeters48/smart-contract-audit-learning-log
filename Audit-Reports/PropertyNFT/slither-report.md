# Slither Analysis – PropertyNFT

## Summary
Contract analyzed: `PropertyNFT.sol`  
Solidity version: ^0.8.22  
Tools: Slither  

## Key Findings
- **Reentrancy Risk** in `withdrawFunds()`  
- **Block.timestamp comparisons** in compliance checks  
- **Costly operations inside loops** in `approveProperty` / `rejectProperty`  
- **Dead code** (unused functions & state variables)  
- **Low-level call** in `withdrawFunds()`  
- **Constant state variables** could be declared  

## Full Tool Output
INFO:Detectors:
PropertyNFT.getComplianceStatus(uint256) (contracts/PropertyNFT.sol#279-281) ignores return value by (GetterLibrary.getComplianceStatus(expiryDates[tokenId],requiredComplianceTypes)) (contracts/PropertyNFT.sol#280)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return
INFO:Detectors:
Reentrancy in PropertyNFT.withdrawFunds() (contracts/PropertyNFT.sol#405-414):
        External calls:
        - (success,None) = address(msg.sender).call{value: amount}() (contracts/PropertyNFT.sol#410)
        Event emitted after the call(s):
        - FundsWithdrawn(msg.sender,amount) (contracts/PropertyNFT.sol#413)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-3
INFO:Detectors:
GetterLibrary.getComplianceStatus(mapping(string => uint256),string[]) (contracts/GetterLibrary.sol#46-57) uses timestamp for comparisons
        Dangerous comparisons:
        - statuses[i] = expiryDates[types[i]] >= block.timestamp (contracts/GetterLibrary.sol#54)
PropertyNFT.isComplianceExpired(uint256,string) (contracts/PropertyNFT.sol#287-289) uses timestamp for comparisons
        Dangerous comparisons:
        - expiryDates[tokenId][complianceType] < block.timestamp (contracts/PropertyNFT.sol#288)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#block-timestamp
INFO:Detectors:
PropertyNFT.unlistProperty(uint256) (contracts/PropertyNFT.sol#359-366) compares to a boolean constant:
        -require(bool,string)(listingProperties[tokenId].forSale == true,Property is not listed) (contracts/PropertyNFT.sol#361)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#boolean-equality
INFO:Detectors:
PropertyNFT.approveProperty(uint256) (contracts/PropertyNFT.sol#189-211) has costly operations inside a loop:
        - pendingApprovalTokens.pop() (contracts/PropertyNFT.sol#206)
PropertyNFT.rejectProperty(uint256) (contracts/PropertyNFT.sol#214-227) has costly operations inside a loop:
        - pendingApprovalTokens.pop() (contracts/PropertyNFT.sol#221)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#costly-operations-inside-a-loop
INFO:Detectors:
PropertyNFT._forceTransfer(address,address,uint256) (contracts/PropertyNFT.sol#332-343) is never used and should be removed
PropertyNFT._increaseBalance(address,uint128) (contracts/PropertyNFT.sol#442-444) is never used and should be removed
PropertyNFT._incrementTotalTokens() (contracts/PropertyNFT.sol#420-422) is never used and should be removed
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dead-code
INFO:Detectors:
Version constraint ^0.8.22 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
        - VerbatimInvalidDeduplication.
It is used by:
        - ^0.8.22 (contracts/AnalyticsLibrary.sol#2)
        - ^0.8.22 (contracts/CreateLibrary.sol#2)
        - ^0.8.22 (contracts/GetterLibrary.sol#2)
        - ^0.8.22 (contracts/PropertyNFT.sol#2)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity
INFO:Detectors:
Low level call in PropertyNFT.withdrawFunds() (contracts/PropertyNFT.sol#405-414):
        - (success,None) = address(msg.sender).call{value: amount}() (contracts/PropertyNFT.sol#410)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls
INFO:Detectors:
PropertyNFT._allTokens (contracts/PropertyNFT.sol#99) is never used in PropertyNFT (contracts/PropertyNFT.sol#13-461)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-state-variable
INFO:Detectors:
Loop condition i < requiredComplianceTypes.length (contracts/PropertyNFT.sol#292) should use cached array length instead of referencing `length` member of the storage array.
 Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#cache-array-length
INFO:Detectors:
PropertyNFT.royaltyFee (contracts/PropertyNFT.sol#29) should be constant
PropertyNFT.royaltyRecipient (contracts/PropertyNFT.sol#30) should be constant
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#state-variables-that-could-be-declared-constant
INFO:Detectors:
The function PropertyNFT._exists(uint256) (contracts/PropertyNFT.sol#425-431) reads owner = this.ownerOf(tokenId) (contracts/PropertyNFT.sol#426-430) with `this` which adds an extra STATICCALL.
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#public-variable-read-in-external-context
INFO:Slither:.\contracts\PropertyNFT.sol analyzed (27 contracts with 100 detectors), 17 result(s) found

