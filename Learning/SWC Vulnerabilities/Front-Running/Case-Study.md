# Malicious user can DoS every account creation by front-running the same accountId (Folks Finance)

**Severity: Medium**

**Summary**
Users must create an account by calling createAccount with a unique accountId. Because accountId is user-supplied and transactions are publicly visible in the mempool (pending tx queue), an attacker can see a legitimate creation request and front-run it with the same accountId. The attacker’s tx lands first, making the user’s tx revert with AccountAlreadyCreated. Repeating this indefinitely causes a platform-wide onboarding DoS.

```solidity
function createAccount(
    bytes32 accountId,
    uint16 chainId,
    bytes32 addr,
    bytes32 refAccountId
) external override onlyRole(HUB_ROLE) {
    // check account is not already created (empty is reserved for admin)
    if (isAccountCreated(accountId) || accountId == bytes32(0))
        revert AccountAlreadyCreated(accountId);

    // check address is not already registered
    if (isAddressRegistered(chainId, addr))
        revert AddressPreviouslyRegistered(chainId, addr);

    // check referrer is well defined
    if (!(isAccountCreated(refAccountId) || refAccountId == bytes32(0)))
        revert InvalidReferrerAccount(refAccountId);

    // create account
    accounts[accountId] = true;
    accountAddresses[accountId][chainId] = AccountAddress({
        addr: addr, invited: false, registered: true
    });
    registeredAddresses[addr][chainId] = accountId;

    emit CreateAccount(accountId, chainId, addr, refAccountId);
}

/*
    What's vulnerable here?
    - First-writer-wins on a user-supplied `accountId` with no ownership proof
    - Mempool visibility: attacker sees victim's `accountId` pre-inclusion
    - Attacker front-runs via higher priority fee; their tx lands first
    - Duplicate guard then reverts the victim: AccountAlreadyCreated(accountId)
    - onlyRole(HUB_ROLE) funnels calls via HUB but does NOT bind `accountId`
*/
```

**Impact**
- Denial of Service: Any new accountId can be pre-claimed; legitimate creations consistently revert.
- Business-critical: Onboarding halts; downstream lending activity blocked.
- Low cost & repeatable: Only gas fees; simple to automate.

**Remediation**
- Signature binding (recommended): Require an EIP-712 signature from the intended owner authorizing (accountId, chainId, addr, - - - - refAccountId, nonce, deadline). Verify on-chain before creation.
- Deterministic IDs: Derive accountId internally (e.g., keccak256(owner, salt)); ensure addr ↔ owner linkage.
- Commit–reveal reservation: Reserve accountId to owner in commit; only that owner can reveal within a window.
- Eliminate user-supplied ids: Use sequential IDs; map human-readable handles separately with signature checks.
