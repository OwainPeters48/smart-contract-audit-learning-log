// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
    What is happening here?
    - This DEX lets users buy tokens at the current price.
    - After each buy, price is increased slightly.

    What's vulnerable here?
    - Attacker watches mempool for a large "buyTokens" tx.
    - They front-run by sending their own tx with higher gas.
    - Their tx executes first, increasing the price.
    - Victim's tx executes second, paying more per token.
    - Attacker can later sell tokens back for a profit.

    What is the mempool?
    - The mempool is the "waiting room" where all pending transactions sit
      before being mined/validated into a block.
    - It's public → anyone can see your tx before it’s confirmed.
    - Attackers/bots scan it 24/7 to find profitable opportunities.
*/

contract VulnerableDEX {
    mapping(address => uint256) public balances;
    uint256 public price = 1 ether; // 1 token = 1 ETH initially

    function buyTokens(uint256 amount) external payable {
        require(msg.value == amount * price, "incorrect ETH");
        balances[msg.sender] += amount;

        // Price increases after each purchase
        price = price + (amount * 0.01 ether);
    }
}
