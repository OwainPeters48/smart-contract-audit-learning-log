// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

contract MissingReturnToken {
    // --- ERC20 Data ---
    string  public constant name = "Token";
    string  public constant symbol = "TKN";
    uint8   public constant decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(uint256 _totalSupply) {
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // NOTE: No returns(bool)
    function transfer(address to, uint256 value) external {
        transferFrom(msg.sender, to, value);
    }

    // NOTE: No returns(bool)
    function transferFrom(address from, address to, uint256 value) public {
        require(balanceOf[from] >= value, "insufficient-balance");

        if (from != msg.sender && allowance[from][msg.sender] != type(uint256).max) {
            require(allowance[from][msg.sender] >= value, "insufficient-allowance");
            allowance[from][msg.sender] -= value;
        }

        balanceOf[from] -= value;
        balanceOf[to]   += value;
        emit Transfer(from, to, value);
    }

    // NOTE: No returns(bool)
    function approve(address spender, uint256 value) external {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }
}
// In this example, the ERC-20 token functions do not return boolean values as per the standard.

// This can lead to compatibility issues with other smart contracts or applications that expect 
// these functions to return a boolean value indicating success or failure.