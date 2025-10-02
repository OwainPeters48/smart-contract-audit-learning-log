# Reentrancy & External Calls in Solidity

Reentrancy happens when a contract makes an **external call** and the called contract executes code that calls back into the original contract before the original contract has finished updating its state.  The result can be drained funds, broken invariants, or unexpected behaviour.  This documents explains the main call types in Solidity and how each one can be abused for reentrancy

## 1. `.call{value: x}(data)`
```solidity
(bool ok, bytes memory res) = recipient.call{value: amount}("");
```
- Behaviour: Low-level call, forwards all available gas by default.
- Risk: Recipient's fallback/receive function can perform arbitrary logic, including re-entering the caller.
- Common exploit: Attacker contract re-calls `withdraw()` before balances are updated.

2. `.transfer(amount)`
```solidity
payable(recipient).transfer(amount);
```
- Behaviour: Forwards a fixed 2300 gas stipend to the recipient's fallback.
- Risk: Used to be considered "safe", but EIPs and gas cost changes make 2300 gas insufficient as a reliable defence.
- Takeaway: Do not rely on `transfer` for reentrancy safety.

3. `.send(amount)`
```solidity
bool success = payable(recipient).send(amount);
```
- Behaviour: Same as `transfer` (2300 gas), but returns a `bool` instead of reverting on failure.
- Risk: Still triggers recipient fallback and therefore allows limited reentrancy attempts.
- Issue: Returning `false` can hide failed sends if not checked properly.

4. High-level external function calls
```solidity
OtherContract(other).doThing(arg);
```
- Behaviour: A normal function call to another contract.
- Risk: Recipient contract executes its own logic fully - including potential callbacks into your contract.
- Example: Lending pool calls borrower, borrower re-enters pool functions.

5. `delegateCall`
```solidity
(bool ok, ) = implementation.delegateCall(data);
```
- Behaviour: Executes code from another contract, but in the storage context of the caller.
- Risk: If the implementation is malicious or unprotected, it can modify storage, drain funds, or call back into functions in the proxy contract.
- Example: Upgradeable proxy misconfigured so attacker can point it to a malicous implementation -> reenters original logic and drains state.

6. ERC777 `tokensReceived` hook
```solidity
// ERC777 transfer triggers tokensReceived on the recipient
token.operatorSend(from, to, amount, "", "");
```
- Behaviour: ERC777 calls`tokensReceived` on the recipient during the transfer flow.
- Risk: The recipient's `tokensReceived` hook can run arbitrary code and call back into the sender contract while the transfer is still in progress.
- Common exploit: Vault sends ERC777 to an address, that address's hook calls back into the vault (e.g., `withdraw()`), exploiting the vault if state wasn't updated first.
- Takeaway: Treat ERC777 transfers as external calls - update state before sending or use defensive guards.

7. ERC721 / ERC1155 `safeTransferFrom` hooks
```solidity
IERC721(nft).safeTransferFrom(address(this), to, tokenId);
```
- Behaviour: `safeTransferFrom` calls `onERC721Received` (or `onERC1155Received`) on the recipient.
- Risk: Recepient callback runs during the transfer and can call back into the sender contract.
- Common exploit: Marketplace transfers an NFT to buyer with `safeTransferFrom`; buyer's `onERC721Received` re-enters marketplace functions to manipulate listings/fees.
- Takeaway: Update marketplace/state before calling `safeTransferFrom` or protect functions with `nonReentrant`.

8. `selfDestruct` (forced ETH transfer)
```solidity
selfDestruct(payable(target));
```
- Behaviour: Destroys the contract and forces its ETH to `target`. The target's fallback/receive executes with full gas (no 2300 limit).
- Risk: An attacker can force-send ETH into your contract and trigger its fallback/receive, which may run code that allows reentry or unexpected state changes.
- Common exploit: Attacker selfdestructs a funded contract to your contract to trigger a fallback that calls back into logic that assumes only internal flows send ETH.
- Takeaway: Keep fallback/receive minimal (don't do complex logic).  Don't rely on the origin of ETH to guarantee safety.

9. Flashloan & Oracle callback flows
```solidity
// Example flashloan callback signature (pseudo)
function executeOperation(address[] calldata assets, uint256[] calldata amounts, bytes calldata params) external returns (bool);
```
- Behaviour: Flashloans and some oracles call a user-supplied callback when you run the logic and must return funds / accept data in the same tx.
- Risk: Callbacks are external points that run while the protocol may be mid-update; an attacker can use them to re-enter or manipulate state (e.g., change prices, trigger liquidation).
- Common exploit: Attacker uses flashloan to move prices or call functions in a specific sequence, then uses callback to call back into the protocol and profit before invariants are restored.
- Takeaway: Validate callback calers (only accept from real flashloan/oracle contracts), use CEI and nonReentrant on callbacks, and add sanity checks.

10. Modifiers / Constructors / Fallback complexity
- Modifiers: A modifier runs code before/after the function body.  If a modifier makes external calls before the function's state updates, that creates a reentrancy window.
    - Example: `modifier check() { helper.pre(); _; helper.post(); }` - if `helper.pre()` calls back into the contract, that's risky.
- Constructors: Rare, but calling untrusted code (or delegatecall) during construction can leave partially-initialised state that attackers exploit.
- Fallback / Receive: These automatically run on ETH transfers or unknown calldata.  If they do anything non-trivial or call external contracts, they are a major risk.
- Takeaway: Keep modifiers simple (avoid external calls), don't call untrusted code in constructors, and keep fallback/receive minimal.


**Key Points**
- Reentrancy can come from many sources beyond `.call` / `.send` / `.transfer`: token hooks, safe transfers, delegatecall, selfdestruct, flashloan/oracle callbacks, and even modifiers/constructors.
- Always assume external interactions might call back into you. Update state first (CEI), use `nonReentrant` as defense-in-depth, and keep automatic entry points (fallback/receive) tiny.
- Static tools help but manual inspection is required for hooks, delegatecall, and upgrade paths.