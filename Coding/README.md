**Staking Contract**

Goal: Users stake an ERC20 token to earn ERC20 rewards linearly over time.

Assumptions:
    Stake token = stakeToken (standard ERC20)
    Reward token = rewardToken (standard ERC20, pre-funded top the contract).
    One pool, constant reward rate (tokens per second).

State you’ll need
    stakeToken, rewardToken (IERC20)
    rewardRate (uint256, tokens/second)
    lastUpdate (uint64/uint40)
    rewardPerTokenStored (fixed-point accumulator)
    userRewardPerTokenPaid[user]
    rewards[user]
    totalStaked
    balances[user]
    (Optional) owner for setRewardRate, fundRewards

Events
    Staked(user, amount)
    Withdrawn(user, amount)
    RewardPaid(user, amount)
    RewardRateUpdated(rate)

Public functions
    stake(uint256 amount)
    withdraw(uint256 amount)
    getReward()
    exit() (withdraw + claim)
    earned(address user) view returns (uint256)
    rewardPerToken() view returns (uint256)
    Admin: setRewardRate(uint256), fundRewards(uint256)

Critical invariants
    Rewards must never exceed tokens actually held for rewards.
    No reentrancy on stake/withdraw/getReward/exit.
    rewardPerToken must be monotonic increasing.
    Precision consistent (choose 1e18 scale).