# [M-08] Users can claim extremely large rewards or lock rewards from LpGauge due to uninitialised `poolLastUpdate` variable

**What is the Issue?**  
In `LpGauge.sol`, the variable `poolLastUpdate` is supposed to track the timestamp of the last reward update.  However, this variable is never initialised on deployment.  In Solidity, uninitialised storage variables default to `0`.

As a result, when `_poolCheckPoint()` is called, the calculation uses `block.timestamp - poolLastUpdate`.  Since `poolLastUpdate` is `0`, the function interprets it as if rewards have been accruing since the Unix epoch (https://en.wikipedia.org/wiki/Unix_time).

This artificially inflates the reward integral, allowing users to either:  
- Claim an extremely large portion of governance tokens for themselves, or  
- Push the integral past the minter's maximum, effectively preventing anyone else from claiming rewards.

**Impact**  
- A user can claim all of the available governance tokens if they stake before `initializeLpGauge()` is called.  
- Alternatively, they can block rewards for everyone else by pushing the reward integral above the mint limit set by `Minter.sol`.  
In both cases, normal reward distribution is broken.  The Code4rena judge classified this as Medium severity since the exploit depends on deployment/initialisation timing or gauge substitution, but the financial consequences are still significant.

**Proof of Concept**  
1.  Deploy contracts - `LpGauge` and `StakerVault` are deployed.  
2.  Stake before initialisation - Before `initializeLpGauge()` is called, User A stakes 1 token using `stakeFor()`  
        - This increases `_poolTotalStaked` by 1.  
        - Since the `lpgauge` address is still the zero address, `_userCheckPoint()` is not called and `poolLastUpdate` remains `0`.  
3.  User calls checkpoint - The user then directly calls `_userCheckPoint()`.  
        - Because `poolLastUpdate == 0`, the reward integral is calculated using `block.timestamp - 0`, which is extremely large.  
4.  Claim rewards - After `initializeLpGauge()` is finally called, the user calls `claimRewards()`.  
        - They receive a disproportionately large portion of governance tokens.  
        - Alternatively, if `poolStakedIntegral` exceeds the mint limit in `Minter.sol`, no one else can claim rewards.

**Mitigation**  
- Initialise `poolLastUpdate` immediately  
    - Set `poolLastUpdate = block.timestamp` in the constructor, or  
    - Ensure it is set during `initializeLpGauge()`.  
- Block early staking  
    - Prevent users from staking before the gauge has been initialised.  
    - Add checks so deposits are only allowed once `poolLastUpdate` is non-zero.  
- Deployment safeguards  
    - When deploying new gauges through `prepareLPGauge()`, ensure that no staking can occur until the gauge is fully initialised with `executeLPGauge()`.  

**Key Takeaways**  
- Always initialise storage variables that affect critical logic (timestamps, counters, integrals).  
- Uninitialised variables default to `0` in Solidity, which can drastically distort calculations.  
- Reward and distribution systems are especially sensitive to incorrect initialisation.  
- Deployment and initialisation sequences must be secured so users cannot interact before state is set.  
- This real-world case shows how a simple oversight can enable either reward theft or denial of service.  
