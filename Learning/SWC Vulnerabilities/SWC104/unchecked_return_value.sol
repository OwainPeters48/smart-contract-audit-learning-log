// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract ReturnValue {
    // Vulnerable: ignores the return values from .call()
    function callNotChecked(address callee) external {
        // Executes fallback() on callee, but success is never checked
        callee.call("");  
    }

    // Safe: captures and checks the return values
    function callChecked(address callee) external {
        (bool success, ) = callee.call("");
        require(success, "External call failed");
    }
}
