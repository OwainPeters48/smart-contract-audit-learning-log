Before Solidity v0.4.22, constructors were defined by naming a function the same as the contract.  If you misspelled the contract name, it wouldn’t act as a constructor, but became a public callable function instead.  This could let anyone reinitialise ownership or critical state.

Reference: [SWC-118 – Incorrect Constructor Name](https://swcregistry.io/docs/SWC-118)
