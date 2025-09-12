// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

/// @title TransferFeeToken
/// @notice ERC20-like token that deducts a percentage fee on every transfer/transferFrom.
/// @dev Intentionally minimal and NOT fully ERC20-compliant (for education).
contract TransferFeeToken {
    // --- ERC20 metadata ---
    string  public constant name     = "Fee Token";
    string  public constant symbol   = "FEE";
    uint8   public constant decimals = 18;

    uint256 public totalSupply;

    // fee in basis points (1 bp = 0.01%). e.g., 300 = 3.00%
    uint16  public immutable feeBps;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from,  address indexed to,      uint256 value);

    constructor(uint256 _totalSupply, uint16 _feeBps) {
        require(_feeBps <= 10_000, "fee too high");
        feeBps = _feeBps;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // --- ERC20-like API (returns bool here, unlike MissingReturnToken) ---

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        if (from != msg.sender) {
            uint256 allowed = allowance[from][msg.sender];
            if (allowed != type(uint256).max) {
                require(allowed >= value, "insufficient-allowance");
                allowance[from][msg.sender] = allowed - value;
            }
        }
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(balanceOf[from] >= value, "insufficient-balance");

        // compute fee and net amount
        uint256 fee = (value * feeBps) / 10_000;
        uint256 net = value - fee;

        // move balances
        balanceOf[from] -= value;
        balanceOf[to]   += net;

        // burn the fee (could instead send to a feeRecipient)
        if (fee != 0) {
            // burning reduces totalSupply
            totalSupply -= fee;
            emit Transfer(from, address(0), fee);
        }

        emit Transfer(from, to, net);
    }
}