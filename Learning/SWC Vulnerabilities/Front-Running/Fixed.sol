// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
    What is happening here?
    - This DEX improves security by forcing buyers to include a "maxPrice"
      they are willing to pay (slippage protection).

    Why is this safer?
    - If attacker front-runs and increases the price,
      the victim’s tx will revert if the price > maxPrice.
    - This prevents victims from being forced into bad trades.
    - It makes sandwich attacks much harder.

    Other mitigations (not shown in code):
    - Commit-reveal schemes (hide trade details until reveal).
    - Private mempool services (e.g., Flashbots).
    - Batch auctions (group orders together so no one can front-run).
*/

contract SafeDEX {
    mapping(address => uint256) public balances;
    uint256 public price = 1 ether;

    function buyTokens(uint256 amount, uint256 maxPrice) external payable {
        // Fix here
        require(price <= maxPrice, "slippage exceeded");
        require(msg.value == amount * price, "incorrect ETH");

        balances[msg.sender] += amount;

        // Price increases after each purchase
        price = price + (amount * 0.01 ether);
    }
}
