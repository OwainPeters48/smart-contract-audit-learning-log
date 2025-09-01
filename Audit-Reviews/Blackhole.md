These notes are based on the Code4rena Blackhole contest audit report. I rewrote a subset of findings (2 High, 2 Medium) in my own words to practice professional audit reporting.

## Blackhole Audit – Report Notes

## Summary

The Code4rena analysis identified a total of 24 unique vulnerabilities:  
- 2 were rated **High** severity,  
- 22 were rated **Medium** severity.  

In addition, the report included 13 further issues classified as **Low severity** or **non-critical**.  

---

## Scope

The audit covered 116 Solidity smart contracts, totalling 10,108 lines of code.  
All reviewed contracts were taken from the Blackhole repository submitted to the Code4rena contest.

---

## Severity Criteria

Code4rena assigns severity levels to reported vulnerabilities as **High**, **Medium**, or **Low/Non-critical**.

When assessing issues, the main factors considered include:
- Malicious Input Handling
- Escalation of privileges
- Arithmetic
- Gas use

---

## High Risk Findings (2)


### High-01 - Incorrect Router Validation in `setRouter()`

**Impact**
The `setRouter(address _router)` function in `GenesisPoolManager` incorrectly requires `_router == address(0)`.
This prevents setting a valid router address, which can block the launch of new pools.  
If `_launchPool` tries to interact with a zero-address router, liquidity could be temporarily locked and protocol functionality disrupted.

**Proof of Concept (PoC)**
```solidity
function setRouter(address _router) external onlyOwner {
    require(_router == address(0), "ZA"); // incorrect check
    router = _router;
}
```

**Recommendation**
- Replace the condition with `require(_router != address(0), "ZA");` to ensure only valid non-zero addresses are allowed.
- If clearing the router is required, implement a separate `clearRouter()` function.

**Patterns to Watch For**
- Require statements that enforce the opposite of the intended logic (e.g., `==` instead of `!=`).
- Always require non-zero addresses unless deliberately clearing state, in which case use a dedicated function.


### High-02 - Missing Access Control in `createGauge()`

**Impact**
The `GaugeFactoryCL.createGauge()` function lacks access control, allowing any external address to call it.
An attacker can repeatedly trigger `createEternalFarming`, causing reward tokens to be redirected into attacker-controlled pools.
This could lead to the complete draining of reward tokens and loss of funds from the protocol.

**Proof of Concept (PoC)**
```solidity
function createGauge(
    address _pool,
    IGaugeManager.FarmingParam memory farmingParam,
    address _rewardToken,
    address _bonusRewardToken
) external returns (address) {
    // ❌ no access control check (e.g., onlyOwner / role)

    createEternalFarming(
        _pool,
        farmingParam.algebraEternalFarming,
        _rewardToken,
        _bonusRewardToken
    );

    last_gauge = address(
        new GaugeCL(
            _rewardToken, _ve, _pool, _distribution,
            _internal_bribe, _external_bribe, _isPair,
            farmingParam, _bonusRewardToken, address(this)
        )
    );

    __gauges.push(last_gauge);
    return last_gauge;
}
```

**Recommendation**
- Restrict access to `createGauge()` using an `onlyOwner` modifier, role-based access control, or a designated factory contract.
- Ensure only authorised administrators or trusted contracts can create new `GaugeCL` instances.

**Patterns to Watch For**
- Critical functions with no `onlyOwner` or role check.
- Functions that trigger token transfers or farming logic should always have strict access control.

---

## Medium Risk Findings (2)


### Medium-01 - Unhandled `permit()` errors in liquidity removal functions

**Impact**
The `RouterV2` contract implements ERC-2612 permit functionality in the function `removeLiquidityWithPermit()` (line 475) and `removeLiquidityETHWithPermit()` (line 493).
Both functions call `permit()` unconditionally without handling errors.
Because ERC-2612 signatures are single-use and nonce-based, a front-runner can consume the user's signature, causing the liquidity removal call to revert.
As a result, users lose gas on failed transactions, must fall back to extra approve + remove steps, and liquidity removal becomes unreliable under active griefing.

**Proof of Concept (PoC)**
```solidity
// RouterV2.sol#L475
IBaseV1Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);

// If this reverts, the entire liquidity removal call fails.
(amountA, amountB) = removeLiquidity(
    tokenA, tokenB, stable, liquidity, amountAMin, amountBMin, to, deadline
);
```

**Recommendation**
Wrap the `permit()` call inside a try/catch block and only revert if both:
1.  The permit fails, and
2.  The current allowance is insufficient for the operation.
This ensures liquidity removals still succeed even if a permit is front-run.

**Patterns to Watch For**
- Functions that call `permit()` or other external signature-based approvals without error handling.  
- Anywhere a nonce-based signature is required → check for front-running / replay risks.  
- External calls in “shortcut” functions (permit + action in one) that revert the whole transaction if the first step fails.  


### Medium-02 – Incorrect use of `block.number` in `getVotes()`

**Impact**
The `getVotes` function in the `BlackGovernor` contract is meant to check a user's voting power at a given point in time, so that governance proposals can be created, voted on, and executed within valid windows.
The issue is that it uses `block.number` instead of `block.timestamp` when determining the point in time.  
Since governance relies on time-based windows rather than block height, this mismatch prevents proposals from functioning as intended and leads to a denial of service in the voting process.
This bug prevents all proposals from being processed or executed correctly, which breaks core governance functionality.

**Proof of Concept (PoC)**
```solidity
// BlackGovernor.sol
require(
    getVotes(_msgSender(), block.number - 1) >= proposalThreshold(),
    "Governor: proposer votes below proposal threshold"
);
```
- The function call passes `block.number - 1` to `getVotes()`, which expects a timestamp.
- Because `block.number` is much smaller than `block.timestamp`, the check always fails, breaking proposal creation.

**Recommendation**
- Change `block.number` to `block.timestamp` to ensure governance windows are correctly validated.
- Add test coverage simulating proposal start and end times to catch similar mistakes in the future.

**Patterns to Watch For**
- Using `block.number` where protocol logic depends on time windows (`block.timestamp` is the correct measure).
- Governance, vesting, or time-lock contracts that rely on timestamps but incorrectly use block height.
- Any mismatch between expected input units (timestamp vs block numbers, seconds vs blocks).

---

## Style Observations

- Findings are grouped by severity (High, Medium, Low, Informational), making it easy for developers to prioritise.  
- Each finding follows a consistent structure: **Impact → Proof of Concept → Recommendation**, which keeps reports readable and standardised.
- Language is concise and avoids unnecessary complexity, making the report understandable for both technical and non-technical readers.
- Reports often generalise specific issues into broader patterns (e.g., missing access control, incorrect input validation), which makes them reusable learning material.  
- Severity criteria are clearly explained at the start so readers know how issues are categorised.  
