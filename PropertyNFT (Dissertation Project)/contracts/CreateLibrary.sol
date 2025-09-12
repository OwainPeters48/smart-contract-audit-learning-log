// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

library CreateLibrary {
    struct Transaction {
        address buyer;
        address seller;
        uint256 price;
    }

    struct MaintenanceRecord {
        string description;
        uint256 cost;
        string[] complianceTypes;
        bool passed;
    }

    function addTransaction(
        Transaction[] storage txs,
        address buyer,
        address seller,
        uint256 price
    ) external {
        txs.push(Transaction(buyer, seller, price));
    }

    function addMaintenanceRecord(
        MaintenanceRecord[] storage records,
        string memory description,
        uint256 cost,
        string[] memory complianceTypes,
        bool passed
    ) external {
        records.push(MaintenanceRecord(description, cost, complianceTypes, passed));
    }

    function addRequiredComplianceType(string[] storage types, string memory newType) external {
        types.push(newType);
    }
}
