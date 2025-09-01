# SWC-119: Shadowing State Variables

In Solidity, if a child contract declares a state variable with the same name as one in the parent contract, it doesn’t override it — it hides (or shadows) it.  
So both are named the same, however use two completely different storage slots.

---

## ❌ Vulnerable Contract – `shadowingBad.sol`

This file demonstrates the issue: `Child` declares an `owner` variable that shadows the `owner` declared in `Parent`.

In Solidity 0.8.22+, this is caught at **compile time**, and the file fails to compile.

### Slither & Compiler Output

- `Identifier already declared`  
- `Cannot override public state variable`  
- `Overriding public state variable is missing "override" specifier`  
- Full Slither scan fails due to compilation error

This confirms that shadowing breaks contract correctness and can lead to bugs in logic or access control.

---

## ✅ Fixed Contract – `shadowingGood.sol`

In the fixed version, `Child` no longer redeclares `owner` and instead uses the inherited `Parent.owner`.

### Slither Output:

- ⚠️ Missing zero-check on `owner = _owner`
- ⚠️ `_owner` parameter not in mixedCase
- ⚠️ Solidity version 0.8.22 flagged for known issues

✅ No shadowing errors — SWC-119 is properly remediated.

---

## 🔧 Remediation

- Review storage variable layouts for your contract systems carefully and remove any ambiguities.  
- Always check for compiler warnings as they can flag the issue within a single contract.

---

## 📚 References

- [SWC Registry – SWC-119](https://swcregistry.io/docs/SWC-119)
