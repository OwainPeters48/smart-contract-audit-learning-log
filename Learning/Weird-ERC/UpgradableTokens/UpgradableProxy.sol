// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Minimal transparent proxy (educational).
contract UpgradableProxy {
    // EIP-1967 implementation slot: bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1)
    bytes32 private constant _IMPL_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    // EIP-1967 admin slot
    bytes32 private constant _ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e01ff55aebf6f1a5a6a00000000000000;

    event Upgraded(address indexed implementation);

    constructor(address impl, bytes memory initCalldata) {
        assembly {
            sstore(_ADMIN_SLOT, caller())
            sstore(_IMPL_SLOT, impl)
        }
        if (initCalldata.length > 0) {
            (bool ok,) = impl.delegatecall(initCalldata);
            require(ok, "init failed");
        }
    }

    function admin() external view returns (address a) {
        assembly { a := sload(_ADMIN_SLOT) }
    }

    function implementation() external view returns (address i) {
        assembly { i := sload(_IMPL_SLOT) }
    }

    function upgradeTo(address newImpl) external {
        address a;
        assembly { a := sload(_ADMIN_SLOT) }
        require(msg.sender == a, "not admin");
        assembly { sstore(_IMPL_SLOT, newImpl) }
        emit Upgraded(newImpl);
    }

    fallback() external payable {
        assembly {
            let impl := sload(_IMPL_SLOT)
            calldatacopy(0, 0, calldatasize())
            let ok := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch ok
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}
