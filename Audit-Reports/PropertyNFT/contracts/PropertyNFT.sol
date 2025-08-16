// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./GetterLibrary.sol";
import "./CreateLibrary.sol";
import "./AnalyticsLibrary.sol";

contract PropertyNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, AccessControl {
    using AnalyticsLibrary for AnalyticsLibrary.Analytics;
    using GetterLibrary for GetterLibrary.Property;
    using GetterLibrary for GetterLibrary.Transaction[];
    using CreateLibrary for CreateLibrary.Transaction[];
    using CreateLibrary for CreateLibrary.MaintenanceRecord[];
    using CreateLibrary for string[];

    struct ListingProperty {
        uint256 price;
        bool forSale;
    }

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");

    uint256 public royaltyFee = 500;
    address public royaltyRecipient;
    string[] public requiredComplianceTypes;
    


    mapping(uint256 => GetterLibrary.Property) public properties;
    mapping(uint256 => CreateLibrary.Transaction[]) private transactions;
    mapping(uint256 => CreateLibrary.MaintenanceRecord[]) public maintenanceRecords;
    mapping(uint256 => mapping(string => uint256)) public expiryDates;
    mapping(uint256 => string) public propertyDocuments;
    mapping(uint256 => ListingProperty) public listingProperties;
    mapping(address => uint256) private pendingWithdrawals;
    mapping(uint256 => address[]) public ownershipHistory;
    mapping(uint256 => mapping(address => bool)) public escrowApprovals;
    mapping(uint256 => bool) public approvedProperties;
    mapping(uint256 => AnalyticsLibrary.ComplianceChecklist) private complianceChecks;
    mapping(uint256 => AnalyticsLibrary.Analytics) private analytics;
    mapping(uint256 => string[]) public propertyImages;
    
    event PropertyMinted(uint256 indexed tokenId, address indexed owner);
    event PropertyBurned(uint256 tokenId, address owner);
    event PropertyUpdated(uint256 indexed tokenId, string newAddress, string newDetails);
    event TransactionRecorded(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);
    event MaintenanceRecordadded(uint256 indexed tokenId, string description, uint256 cost, bool passed);   
    event ComplianceExpired(uint256 indexed tokenId, string complianceType, uint256 expiryDate);
    event ComplianceValidated(uint256 indexed tokenId, bool isCompliant);
    event PropertyTransferred(uint256 indexed tokenId, address from, address to);
    event PropertySold(uint256 indexed tokenId, address seller, address buyer, uint256 price);
    event FundsWithdrawn(address indexed seller, uint256 amount);
    event EscrowFinalized(uint256 tokenId, address newOwner);
    event EscrowInitiated(uint256 tokenId, address buyer, address seller, uint256 amount);
    event PropertyPendingApproval(uint256 tokenId, address mintedBy);
    event PropertyApproved(uint256 tokenId);
    event PropertyRejected(uint256 tokenId);
    event PropertyPriceUpdated(uint256 tokenId, uint256 newPrice);

    constructor() ERC721("PropertyNFT", "PRP") Ownable(msg.sender) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(COMPLIANCE_ROLE, msg.sender);

        requiredComplianceTypes.push("FireSafety");
        requiredComplianceTypes.push("ElectricalCheck");
    }



    function getPropertyDetails(uint256 tokenId) public view returns (
        string memory, 
        uint256, 
        string memory, 
        uint256,
        bool
    ) {
        require(_exists(tokenId), "Property does not exist");

        GetterLibrary.Property memory details = properties[tokenId];
        ListingProperty memory listing = listingProperties[tokenId];

        return (
            details.propertyAddress,
            details.ownershipHistory,
            details.transactionDetails,
            listing.price,
            listing.forSale
        );
    }


    uint256[] private _allTokens;
    function totalSupply() public view override returns (uint256) {
        return super.totalSupply();
    }

    function getMintedTokens() public view returns (uint256[] memory) {
        uint256 supply = totalSupply();
        uint256[] memory tokens = new uint256[](supply);
        for (uint256 i = 0; i < supply; i++) {
            tokens[i] = tokenByIndex(i);
        }
        return tokens;
    }

    uint256[] public pendingApprovalTokens;

    function getPendingApprovalTokens() public view returns (uint256[] memory) {
        return pendingApprovalTokens;
    }

    function getAnalytics(uint256 tokenId) public view returns (uint256, uint256) {
        require(_exists(tokenId), "Token does not exist");
        AnalyticsLibrary.Analytics memory data = analytics[tokenId];
        return (data.totalSales, data.highestSalePrice);
    }

    function getCompliance(uint256 tokenId) public view returns (
        bool, bool, bool, bool, string memory
    ) {
        require(_exists(tokenId), "Token does not exist");
        AnalyticsLibrary.ComplianceChecklist memory c = complianceChecks[tokenId];
        return (
            c.fireAlarmTested,
            c.gasCertified,
            c.electricalSafetyPassed,
            c.legalApproved,
            c.inspectorNotes
        );
    }

    function updateCompliance(
        uint256 tokenId,
        bool fire,
        bool gas,
        bool electric,
        bool legal,
        string memory notes
    ) public onlyRole(ADMIN_ROLE) {
        require(_exists(tokenId), "Token does not exist");

        AnalyticsLibrary.updateComplianceChecklist(
            complianceChecks[tokenId],
            fire,
            gas,
            electric,
            legal,
            notes
        );
    }



    function mintPropertyNFT(
        uint256 tokenId,
        string memory propertyAddress,
        string memory transactionDetails,
        uint256 price
    ) public {
        require(!_exists(tokenId), "Token already exists");

        properties[tokenId] = GetterLibrary.Property({
            propertyAddress: propertyAddress,
            ownershipHistory: 0,
            transactionDetails: transactionDetails
        });

        listingProperties[tokenId].price = price;
        listingProperties[tokenId].forSale = false;

        _mint(msg.sender, tokenId);

        ownershipHistory[tokenId].push(msg.sender);

        approvedProperties[tokenId] = false;
        pendingApprovalTokens.push(tokenId);

        emit PropertyMinted(tokenId, msg.sender);
        emit PropertyPendingApproval(tokenId, msg.sender);
    }

    function approveProperty(uint256 tokenId) public onlyRole(ADMIN_ROLE) {
        require(_exists(tokenId), "Token does not exist");
        require(!approvedProperties[tokenId], "Already approved");

        AnalyticsLibrary.ComplianceChecklist storage c = complianceChecks[tokenId];
        require(
            c.fireAlarmTested &&
            c.gasCertified &&
            c.electricalSafetyPassed &&
            c.legalApproved,
            "Property is not fully compliant"
        );
        approvedProperties[tokenId] = true;

        for (uint i = 0; i < pendingApprovalTokens.length; i++) {
            if (pendingApprovalTokens[i] == tokenId) {
                pendingApprovalTokens[i] = pendingApprovalTokens[pendingApprovalTokens.length - 1];
                pendingApprovalTokens.pop();
                break;
            }
        }
        emit PropertyApproved(tokenId);
    }


function rejectProperty(uint256 tokenId) public onlyRole(ADMIN_ROLE) {
    require(_exists(tokenId), "Token does not exist");
    require(!approvedProperties[tokenId], "Property already approved");

    for (uint i = 0; i < pendingApprovalTokens.length; i++) {
        if (pendingApprovalTokens[i] == tokenId) {
            pendingApprovalTokens[i] = pendingApprovalTokens[pendingApprovalTokens.length - 1];
            pendingApprovalTokens.pop();
            break;
        }
    }

    emit PropertyRejected(tokenId);
}

function updateListingPrice(uint256 tokenId, uint256 newPrice) public {
    require(ownerOf(tokenId) == msg.sender, "Only property owner can update the price");
    require(listingProperties[tokenId].forSale, "Property must be listed for sale");
    
    listingProperties[tokenId].price = newPrice;

    emit PropertyPriceUpdated(tokenId, newPrice);
}

function addPropertyImages(uint256 tokenId, string[] memory imageUrls) public {
    require(ownerOf(tokenId) == msg.sender, "Not the owner");

    for (uint256 i = 0; i < imageUrls.length; i++) {
        propertyImages[tokenId].push(imageUrls[i]);
    }
}


function getPropertyImages(uint256 tokenId) public view returns (string[] memory) {
    return propertyImages[tokenId];
}


    function updatePropertyDetails(
        uint256 tokenId,
        string memory newAddress,
        string memory newDetails
    ) public onlyRole(ADMIN_ROLE) {
        require(_exists(tokenId), "Token does not exist");
        properties[tokenId].propertyAddress = newAddress;
        properties[tokenId].transactionDetails = newDetails;
        emit PropertyUpdated(tokenId, newAddress, newDetails);
    }

    function recordTransaction(
        uint256 tokenId,
        address buyer,
        address seller,
        uint256 price
    ) public onlyRole(ADMIN_ROLE) {
        require(_exists(tokenId), "Token does not exist");
        require(validateCompliance(tokenId), "Property is not compliant");
        transactions[tokenId].addTransaction(buyer, seller, price);
        analytics[tokenId].recordSale(price);
        emit TransactionRecorded(tokenId, buyer, seller, price);
        emit ComplianceValidated(tokenId, true);
    }

    

    function getComplianceStatus(uint256 tokenId) public view returns(string[] memory, bool[] memory) {
        return(GetterLibrary.getComplianceStatus(expiryDates[tokenId], requiredComplianceTypes));
    }

    function addRequriedComplianceType(string memory complianceType) public onlyRole(ADMIN_ROLE) {
        CreateLibrary.addRequiredComplianceType(requiredComplianceTypes, complianceType);
    }

    function isComplianceExpired(uint256 tokenId, string memory complianceType) public view returns (bool) {
        return expiryDates[tokenId][complianceType] < block.timestamp;
    }

    function validateCompliance(uint256 tokenId) public view returns (bool) {
        for (uint256 i = 0; i < requiredComplianceTypes.length;   i++) {
            if (isComplianceExpired(tokenId, requiredComplianceTypes[i])) {
                return false;
            }
        }
        return true;
    }

    

    function burn(uint256 tokenId) public onlyRole(ADMIN_ROLE) {
        require(_exists(tokenId), "Token does not exist");

        address owner = ownerOf(tokenId);
        _burn(tokenId);
        delete properties[tokenId];
        delete transactions[tokenId];

        emit PropertyBurned(tokenId, owner);
    }

    function transferPropertyNFT(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != address(0), "Cannot transfer to zero address");
        require(
            owner == _msgSender() || 
            getApproved(tokenId) == _msgSender() || 
            isApprovedForAll(owner, _msgSender()),
            "Not authorized to transfer"
        );

        _safeTransfer(owner, to, tokenId, "");

        if (ownershipHistory[tokenId].length == 0 || ownershipHistory[tokenId][ownershipHistory[tokenId].length - 1] != owner) {
            ownershipHistory[tokenId].push(owner);
        }

        emit PropertyTransferred(tokenId, owner, to);
    }

    function _forceTransfer(address from, address to, uint256 tokenId) internal {
        require(from != address(0), "Invalid sender");
        require(to != address(0), "Invalid recipient");

        _safeTransfer(from, to, tokenId, "");

        if (ownershipHistory[tokenId].length == 0 || ownershipHistory[tokenId][ownershipHistory[tokenId].length - 1] != from) {
            ownershipHistory[tokenId].push(from);
        }

        emit PropertyTransferred(tokenId, from, to);
    }

    function getOwnershipHistory(uint256 tokenId) public view returns (address[] memory) {
        return ownershipHistory[tokenId];
    }

    function listPropertyForSale(uint256 tokenId, uint256 priceInWei) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(priceInWei > 0, "Price must be greater than 0");
        require(approvedProperties[tokenId], "Property not approved for listing");

        listingProperties[tokenId] = ListingProperty(priceInWei, true);
        emit TransactionRecorded(tokenId, address(0), msg.sender, priceInWei);
    }


    function unlistProperty(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(listingProperties[tokenId].forSale == true, "Property is not listed");

        listingProperties[tokenId].forSale = false;

        emit TransactionRecorded(tokenId, msg.sender, address(0), 0);
    }


    function buyProperty(uint256 tokenId) external payable {
        ListingProperty memory listing = listingProperties[tokenId];
        require(approvedProperties[tokenId], "Property not approved for sale");

        uint256 price = listing.price;
        require(msg.value >= price, "Insufficient ETH sent");

        address seller = ownerOf(tokenId);
        require(seller != msg.sender, "You cannot buy your own property");

        pendingWithdrawals[seller] += msg.value;
        _transfer(seller, msg.sender, tokenId);
        ownershipHistory[tokenId].push(msg.sender);

        listingProperties[tokenId].forSale = false;

        AnalyticsLibrary.recordSale(analytics[tokenId], msg.value);

        emit PropertySold(tokenId, seller, msg.sender, price);
        emit TransactionRecorded(tokenId, msg.sender, seller, price);
    }





    function getPrice(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "Property does not exist");
        return listingProperties[tokenId].price;
    }


        function isPropertyForSale(uint256 tokenId) public view returns (bool) {
            return listingProperties[tokenId].forSale;
        }

        function withdrawFunds() external {
            uint256 amount = pendingWithdrawals[msg.sender];
            require(amount > 0, "No funds to withdraw");

            pendingWithdrawals[msg.sender] = 0;
            (bool success, ) = payable(msg.sender).call{value: amount}("");
            require(success, "Withdrawal failed");

            emit FundsWithdrawn(msg.sender, amount);
        }


    
    uint256 private _totalTokens;

    function _incrementTotalTokens() private {
        _totalTokens += 1;
    }


    function _exists(uint256 tokenId) internal view returns (bool) {
        try this.ownerOf(tokenId) returns (address owner) {
            return owner != address(0);
        } catch {
            return false;
        }
    }

function getOwnedTokens(address owner) public view returns (uint256[] memory) {
        uint256 balance = balanceOf(owner);
        uint256[] memory tokens = new uint256[](balance);
        for (uint256 i = 0; i < balance; i++) {
            tokens[i] = tokenOfOwnerByIndex(owner, i);
        }
        return tokens;
    }

function _increaseBalance(address account, uint128 value) internal virtual override(ERC721, ERC721Enumerable) {
    super._increaseBalance(account, value);
}

function _update(address to, uint256 tokenId, address auth) internal virtual override(ERC721, ERC721Enumerable) returns (address) {
    return super._update(to, tokenId, auth);
}

function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
    return super.tokenURI(tokenId);
}

function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
}


    
}
