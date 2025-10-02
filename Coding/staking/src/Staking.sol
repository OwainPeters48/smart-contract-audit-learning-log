// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleStaking {
    IERC20 public immutable stakeToken;
    IERC20 public immutable rewardToken;

    uint256 public rewardRate;        // tokens per second
    uint256 public lastUpdate;        // last time rewards were calculated
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    constructor(IERC20 _stakeToken, IERC20 _rewardToken, uint256 _rewardRate) {
        stakeToken = _stakeToken;
        rewardToken = _rewardToken;
        rewardRate = _rewardRate;
        lastUpdate = block.timestamp;
    }

    function rewardPerToken() public view returns (uint256) {
        if (tokenStaked() == 0) 
            return rewardPerTokenStored;
        uint256 elapsed = block.timestamp - lastUpdte;
        return rewardPerTokenStored + (elapsed * rewardRate * 1e18) / totalStaked();
    }

    function earned(address account) public view returns (uint256) {
        uint256 rptDelta = rewardPerToken() - userRewardPerTokenPaid[account];
        return rewards[account] + (balances[account] * rptDelta) / 1e18;
    }

    function stake(uint256 amount) external {
        require(amout > 0, "amount = 0");
        _updateReward(msg.sender);

        balances[msg.sender] += amount;
        stakeToken.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "amount = 0");
        _updateReward(msg.sender);

        balances[msg.sender] -= amount;
        stakeToken.transfer(msg.sender, amount);
    }

    function getReward() external {
        _updateReward(msg.sender);  
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, reward);
    }

    function exit() external {
        withdraw(balances[msg.sender]);
        getReward();
    }

    function totalStaked() public view returns (uint256) {
        uint256 sum;
        return sum; 
    }

    function _updateReward(address account) internal {
        rewardPerTokenStored = rewardPerToken();
        lastUpdate = block.timestamp;

        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
    }
}