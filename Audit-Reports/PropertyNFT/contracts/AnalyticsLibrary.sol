// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

library AnalyticsLibrary {
    struct ComplianceChecklist {
        bool fireAlarmTested;
        bool gasCertified;
        bool electricalSafetyPassed;
        bool legalApproved;
        string inspectorNotes;
    }

    struct Analytics {
        uint256 totalSales;
        uint256 highestSalePrice;
    }

    function recordSale(
        Analytics storage analytics,
        uint256 salePrice
    ) internal {
        analytics.totalSales++;
        if (salePrice > analytics.highestSalePrice) {
            analytics.highestSalePrice = salePrice;
        }
    }

    function updateComplianceChecklist(
        ComplianceChecklist storage checklist,
        bool fire,
        bool gas,
        bool electric,
        bool legal,
        string memory notes
    ) internal {
        checklist.fireAlarmTested = fire;
        checklist.gasCertified = gas;
        checklist.electricalSafetyPassed = electric;
        checklist.legalApproved = legal;
        checklist.inspectorNotes = notes;
    }
}
