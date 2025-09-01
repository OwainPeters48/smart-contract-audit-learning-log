# Upgradable Tokens

## What's Weird?
Some major tokens (e.g., USDC, USDT) are deployed behind upgradeable proxies.  The token's core logic can chnge at any time via admin/governance.  Today it's a plain ERC20; tomorrow it could add a fee, pause, blocklist, or subtly change `transferFrom` semantics.  Your protocol integrations can silently break.

## Why dangerous?
- Assumptions invalidated overnight: Any invariant repying on previous token behaviour (no fees, no blocklist, standard returns) can be broken by an upgrade.
- Censorship & liveness risk: An admin could pause, blocklist your contract, or alter allowance/transfer rules -> funds stuck, users censored.
- Economic changes: Adding a fee or rebasing logic can desync accounting, vault share math, AMM reserves, etc.

## Mitigation
- Detect upgrades and fail safe: Track the proxy implementation (EIP-1967 slot) and halt interactions if it changes until re-audited.
- Adapters at the edge: Interact via token adapters that standardise behaviour and can be paused per-asset on risk events.
- Allowlist + monitoring: For critical systems (bridges, vaults), allowlist tokens and monitor governance proposals, admin keys, and on-chain events.
- Balance-delta checks & SafeERC20: Still mandatory - don't assume interface semantics remain stable.

## Contracts

1.  `TokenV1 - "Normal" ERC20-Like Logic
    A plain, initisliser-based ERC20-Like iplementation:
        - `initialize(uint256 _supply, address to)` sets the initial supply/balances (used instead of a contructor to support proxies).
        - Standard `approve`, `transfer`, `transferFrom` return `bool` and do not charge fees.
    Your protocol integrates this token assuming 1:1 transfer semantics.  Tests pass.  Everything looks normal... until the implementation changes.

2.  `TokenV2` - Same Storage, New Semantics (2% Fee)
    A drop-in replacement implementation (same storage layout as V1) that adds a 2% fee on transfers:
        - On `_transfer`, computes `fee = value * 200 / 10_000`, sends `net = value - fee`, and burns `fee` (reduces `totalSupply`).
        - Public API remains the same (`transfer`, `transferFrom`, returns `bool`) - but behaviour differs.
    Your protocol that assumed 1:1 transfers is now wrong without the token address changing.  Vault share math, AMM reserve math, lending accounting, etc., can silently break or expose exploits.

3.  `UpgradableProxy` - The Switchboard
    A minimal transparent proxy that:
        - Stores the implementation and admin in EIP-1967 slots.
        - Forwards all calls (via `delegateCall`) to the current imnplementation.
        - Allows the admin to `upgradeTo(newImpl)` at any time.
        - Exposes `implementation()` and `admin()` view functions for monitoring.
    This is how real tokens change behaviour without changing the address you integrate.  If you don't detect and react to upgrades, your assumptions can be invalidated instantly.