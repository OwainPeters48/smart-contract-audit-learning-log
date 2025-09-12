# Uninitialised Storage Pointers

**What is an Uninitialised Storage Pointer?**
In Solidity, storage and memory behave very differently.  If a storage pointer (like a struct or array reference) is declared but never initialised, it may end up pointing to slot 0 in storage by default.  This means writes to the variable can unintentionally overwrite critical state like the contract owner, balances, or configuration.
This is not a "syntax error" - the code compiles fine, but the logic silently corrupts storage.

**Why it Matters in Security**
- Silent Corruption - Developers assumew the variable is "empty", but it's actually writing to an unintended location.
- Privilege Escalation - If the overwritten slot is access control (like `owner`), an attacker could gain admin rights.
- Difficult to Detect - Code looks normal, but behaviour changes completely at runtime.
- Legacy Risk - More commoon in older Solidity code, but still shows up in audits of projects written without modern linters.

**Common Exploits Enabled by Uninitialised Variables**
1.  Overwriting Ownership
    - A struct pointer defaults to slot 0.  Writing to it overwrites `owner` variable.
    - Attackere calls the vulnerable function, overwrites storage, becomes the contract owner.
    - Case Study: Multiple historical CTF challenges simulate this bug.
2.  Bypassing Balances / State Checks
    - Uninitialised array pointers can overwrite mappings.
    - Balances or allowances can be reset, letting attacker withdraw or spend tokens.
3.  Constructor Bugs
    - Forgetting to initialise critical values in the constructor (e.g., not setting `owner`).
    - Attacker later calls a function meant to be restricted, seizes control.
4.  Library Function Pitfalls
    - Passing uninitialised storage variables into libraries that assume they're valid.
    - Library ends up corrupting unrelated storage slots.

**Key Risk Factors**
- Developers unaware of default storage slot 0 behaviour.
- Complex structs/arrays declared but not explicitly initialised.
- Critical contract state stored at low slots (`owner`, `balances`).
- Constructors missing explicit initialisation logic.

**Mitigations**
- Always initialise storage variables explicitly in constructors.
- use linters (Slither, Aderyn) to flag uninitialised variables.
- Avoid passing storage pointers into libraries unless verified.
- Add tests to confirm `owner`, balances, and configs cannot be overwritten post-deployment.