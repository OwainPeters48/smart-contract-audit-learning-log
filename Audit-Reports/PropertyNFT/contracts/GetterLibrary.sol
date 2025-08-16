// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

library GetterLibrary {
    struct Property {
        string propertyAddress;
        uint256 ownershipHistory;
        string transactionDetails;
    }

    struct Transaction {
        address buyer;
        address seller;
        uint256 price;
        uint256 timestamp;
    }

    struct MaintenanceRecord {
        string description;
        uint256 cost;
        uint256 timestamp;
        string[] complianceTypes;
        bool passed;
    }

    function getProperty(Property storage property) external view returns (string memory, uint256, string memory) {
        return (property.propertyAddress, property.ownershipHistory, property.transactionDetails);
    }

    function getTransactionHistory(Transaction[] memory transactions) external pure returns (Transaction[] memory) {
        return transactions;
    }

    function getMaintenanceRecord(MaintenanceRecord[] memory records) external pure returns (MaintenanceRecord[] memory) {
        return records;
    }

    function getComplianceExpiryDate(
        mapping(uint256 => mapping(string => uint256)) storage expiryDates,
        uint256 tokenId,
        string memory complianceType
    ) external view returns (uint256) {
        return expiryDates[tokenId][complianceType];
    }

    function getComplianceStatus(
        mapping(string => uint256) storage expiryDates,
        string[] memory requiredComplianceTypes
    ) external view returns(string[] memory, bool[] memory) {
        string[] memory types = requiredComplianceTypes;
        bool[] memory statuses = new bool[](types.length);

        for (uint256 i = 0; i < types.length; i++) {
            statuses[i] = expiryDates[types[i]] >= block.timestamp;
        }
        return (types, statuses);
    }

    
}