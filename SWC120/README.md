# SWC-120: Weak Sources of Randomness

On Ethereum, there is no native randomness. Any “randomness” made from block values or public state is predictable and/or miner-biasable.

## Common Bad Sources
- `block.timestamp`, `block.number`, `blockhash(block.number-1)`, `gasleft()`
- `msg.sender`, `tx.origin`, contract balances, nonces
- Hashing the above (e.g., `keccak256(abi.encodePacked(...)))` does not make them random.

## Exploit Paths
- **Miner/validator bias**: withholds/chooses a block to sway the outcome.  
- **User timing/brute force**: attacker spams entries / times a tx to hit a favourable modulus.  
- **MEV backrun/ordering**: attacker sees your call, computes the outcome, then reorders/duplicates to win.  

## Remediation
- Use external sources of randomness via oracles.  
- Use Bitcoin block hashes, as they are more expensive to mine.  
