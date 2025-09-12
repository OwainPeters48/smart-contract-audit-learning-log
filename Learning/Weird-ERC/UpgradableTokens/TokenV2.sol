// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TokenV2_Fee {
    // storage must match V1 layout
    string public constant name = "Upgradable Token";
    string public constant symbol = "UPG";
    uint8  public constant decimals = 18;

    uint256 public totalSupply;
    mapping(address => uint256)                      public balanceOf;
    mapping(address => mapping(address => uint256))  public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint16 public constant feeBps = 200; // 2%

    function initialize(uint256, address) external {
        // no-op to keep initializer signature; already initialised in V1
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        return _transfer(msg.sender, to, value);
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        if (from != msg.sender) {
            uint256 a = allowance[from][msg.sender];
            if (a != type(uint256).max) {
                require(a >= value, "insufficient-allowance");
                allowance[from][msg.sender] = a - value;
            }
        }
        return _transfer(from, to, value);
    }

    function _transfer(address from, address to, uint256 value) internal returns (bool) {
        require(balanceOf[from] >= value, "insufficient-balance");
        uint256 fee = (value * feeBps) / 10_000;
        uint256 net = value - fee;
        balanceOf[from] -= value;
        balanceOf[to]   += net;

        // burn the fee to illustrate semantic change (could be sent to feeRecipient)
        totalSupply -= fee;

        emit Transfer(from, to, net);
        if (fee != 0) emit Transfer(from, address(0), fee);
        return true;
    }
}
