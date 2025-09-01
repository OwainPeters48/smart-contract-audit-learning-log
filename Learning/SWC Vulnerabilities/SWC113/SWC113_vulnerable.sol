// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract RefundAll_DoS {
    mapping(address => uint256) public refunds;
    address[] public recipients;

    function seed(address[] calldata addrs, uint256 amountEach) external payable {
        require(msg.value == amountEach * addrs.length, "bad funding");
        for (uint i; i < addrs.length; i++) {
            recipients.push(addrs[i]);
            refunds[addrs[i]] = amountEach;
        }
    }

    // Vulnerable: one recipient reverting blocks everyone (SWC-113)
    function refundAll() external {
        for (uint i; i < recipients.length; i++) {
            address to = recipients[i];
            uint256 amt = refunds[to];
            if (amt == 0) continue;

            // either .send(...) or .call{value: amt}("")
            (bool ok, ) = payable(to).call{value: amt}("");
            require(ok, "refund failed"); // <- a single revert DoS’es the whole loop
            refunds[to] = 0;
        }
    }

    receive() external payable {}
}
