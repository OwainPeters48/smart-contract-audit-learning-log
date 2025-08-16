SWC-100: Function Default Visibility
📖 Summary

In Solidity versions prior to 0.5.0, functions without an explicitly declared visibility default to public.
This means anyone could call them, even if the developer intended them to be internal-only.

Such a mistake could allow:

Unauthorized state changes

Asset theft

Logic abuse

Always explicitly declare function visibility (external, public, internal, private) to avoid unexpected behavior.

🔎 Audit Checklist

 Does every function explicitly declare visibility?

 Are helper functions restricted with internal or private where possible?

 Could any unintended external calls happen?

📝 Notes

This vulnerability is mostly relevant for legacy contracts (<0.5.0).

Modern compilers will throw an error if visibility is not specified.

Still, best practice is to always declare visibility explicitly.
