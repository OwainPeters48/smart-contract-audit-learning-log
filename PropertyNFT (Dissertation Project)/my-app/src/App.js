/* global BigInt */

import React, { useState, useEffect, useCallback } from "react";
import { ethers } from "ethers";
import { keccak256, toUtf8Bytes } from "ethers/lib/utils";
import PropertyNFT from "./PropertyNFTABI.json";
import { ToastContainer, toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min";
import Spinner from "react-bootstrap/Spinner";
import { Carousel } from 'react-responsive-carousel';
import "react-responsive-carousel/lib/styles/carousel.min.css";
import axios from 'axios';


console.log("App.js is running at:", new Date().toISOString());

const App = () => {
  const [walletConnected, setWalletConnected] = useState(false);
  const [account, setAccount] = useState("");
  const [contract, setContract] = useState(null);
  const [propertyDetails, setPropertyDetails] = useState(null);
  const [loading, setLoading] = useState(false);
  const [ownedNFTs, setOwnedNFTs] = useState([]);
  const [currentTokenId, setCurrentTokenId] = useState(null);
  const [ethBalance, setEthBalance] = useState(null);
  const [allProperties, setAllProperties] = useState([]);
  const [filteredProperties, setFilteredProperties] = useState([]);
  const [eventLogs, setEventLogs] = useState([]);
  const [showEventLogs, setShowEventLogs] = useState(false);
  const [pendingApprovals, setPendingApprovals] = useState([]);
  const [fireAlarmChecked, setFireAlarmChecked] = useState(false);
  const [gasCertifiedChecked, setGasCertifiedChecked] = useState(false);
  const [electricalSafeChecked, setElectricalSafeChecked] = useState(false);
  const [legalApprovedChecked, setLegalApprovedChecked] = useState(false);
  const [inspectorNotes, setInspectorNotes] = useState("");
  const [newPrice, setNewPrice] = useState("");
  const [galleryExpanded, setGalleryExpanded] = useState(false);

  const PINATA_API_KEY = process.env.REACT_APP_PINATA_API_KEY;
  const PINATA_SECRET_API_KEY = process.env.REACT_APP_PINATA_SECRET_KEY;

  console.log("App.js is running at:", new Date().toISOString());

  const contractAddress = process.env.REACT_APP_CONTRACT_ADDRESS;

  const [isAdmin, setIsAdmin] = useState(false);

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        await window.ethereum.request({ method: "eth_requestAccounts" });

        const accounts = await provider.listAccounts();
        if (accounts.length === 0) {
          toast.error("No accounts found. Please connect to MetaMask.");
          return;
        }

        const account = accounts[0];
        setAccount(account);
        setWalletConnected(true);
        console.log("Connected Account:", account);

        let balance = await provider.getBalance(account);
        balance = ethers.BigNumber.isBigNumber(balance) ? balance : ethers.BigNumber.from(balance.toString());
        const formattedBalance = ethers.utils.formatEther(balance);
        setEthBalance(formattedBalance);
        console.log("ETH Balance:", formattedBalance);

        const contractInstance = new ethers.Contract(contractAddress, PropertyNFT.abi, provider.getSigner());
        setContract(contractInstance);
        window.contract = contractInstance;
        console.log("Contract Instance Loaded:", contractInstance);

        const ADMIN_ROLE = keccak256(toUtf8Bytes("ADMIN_ROLE"));
        const hasRole = await contractInstance.hasRole(ADMIN_ROLE, account);
        setIsAdmin(hasRole);
        if (hasRole) {
          toast.success("You have ADMIN_ROLE!");
          console.log("User is Admin!");
        } else {
          toast.warn("You do NOT have ADMIN_ROLE.");
          console.log("User is NOT an Admin");
        }
      } catch (error) {
        console.error("Error connecting wallet:", error.message);
        toast.error("Error connecting wallet: " + error.message);
      }
    } else {
      toast.error("MetaMask is not installed. Please install it to use this app.");
    }
  };

  const getPropertyDetails = async (tokenId) => {
    if (!contract) return toast.error("Contract not loaded yet.");
    if (!tokenId || isNaN(tokenId)) return toast.warn("Please enter a valid Token ID.");
  
    try {
      setLoading(true);
      console.log(`Checking if Token ID ${tokenId} exists...`);
  
      let currentOwner;
      try {
        currentOwner = await contract.ownerOf(tokenId);
        console.log(`Token ${tokenId} is owned by: ${currentOwner}`);
      } catch (error) {
        toast.error(`Token ${tokenId} does not exist.`);
        return;
      }
  
      let details, listing, history, analytics, compliance;
      try {
        details = await contract.getPropertyDetails(tokenId);
        listing = await contract.listingProperties(tokenId);
        history = await contract.getOwnershipHistory(tokenId);
  
        const analyticsRaw = await contract.getAnalytics(tokenId);
        analytics = {
          totalSales: analyticsRaw[0].toString(),
          highestSalePrice: ethers.utils.formatEther(analyticsRaw[1]),
        };
  
        const complianceRaw = await contract.getCompliance(tokenId);
        compliance = {
          fireAlarmTested: complianceRaw[0],
          gasCertified: complianceRaw[1],
          electricalSafetyPassed: complianceRaw[2],
          legalApproved: complianceRaw[3],
          inspectorNotes: complianceRaw[4],
        };
  
        console.log("Raw Property Details:", details);
        console.log("Raw Listing Details:", listing);
        console.log("Ownership History:", history);
        console.log("Analytics:", analytics);
        console.log("Compliance:", compliance);
      } catch (error) {
        console.error("Error fetching details:", error);
        return toast.error("Error fetching property details.");
      }
  
      const formattedHistory = [
        `Current Owner: ${currentOwner}`,
        ...history.map((addr, index) => `#${index + 1}: ${addr}`),
      ];
  
      const rawPrice = ethers.BigNumber.isBigNumber(listing[0])
        ? listing[0]
        : ethers.BigNumber.from(listing[0]);
  
      const formattedPrice = ethers.utils.formatEther(rawPrice);
      const approved = await getApprovalStatus(tokenId);
      const images = await contract.getPropertyImages(tokenId);
  
      const propertyData = {
        tokenId: tokenId.toString(),
        propertyAddress: details[0] ?? "Unknown Address",
        ownershipHistory: formattedHistory,
        transactionDetails: details[2] ?? "No details available",
        price: rawPrice.toString(),
        priceETH: formattedPrice,
        currentOwner,
        approved,
        propertyImages: images,
        forSale: listing[1],
        analytics,
        compliance,
      };
  
      console.log("Final Property Data:", propertyData);
      setPropertyDetails(propertyData);
      setCurrentTokenId(tokenId.toString());
  
      toast.success("Property details updated successfully!");
    } catch (error) {
      console.error("Fetching Error:", error);
      toast.error("Error fetching property details.");
    } finally {
      setLoading(false);
    }
  };
  
  

const approveProperty = async (tokenId) => {
  if (!contract || !isAdmin) return toast.error("Unauthorized or contract not ready.");
  try {
    const tx = await contract.approveProperty(tokenId);
    await tx.wait();
    toast.success(`Token ID ${tokenId} approved!`);

    setPendingApprovals((prev) =>
      prev.filter((token) => token.tokenId !== tokenId.toString())
    );

    await fetchMintedTokens();
  } catch (error) {
    console.error("Approval failed:", error);
    toast.error("Error approving property: " + error.message);
  }
};


const rejectProperty = async (tokenId) => {
  if (!contract || !isAdmin) return toast.error("Unauthorized or contract not ready.");
  try {
    const tx = await contract.rejectProperty(tokenId);
    await tx.wait();
    toast.success(`Token ID ${tokenId} removed from approval list`);

    setPendingApprovals((prev) =>
      prev.filter((token) => token.tokenId !== tokenId.toString())
    );
  } catch (error) {
    console.error("Rejection failed:", error);
    toast.error("Error rejecting property: " + error.message);
  }
};

const getApprovalStatus = async (tokenId) => {
  if (!contract) return null;
  try {
    const approved = await contract.approvedProperties(tokenId);
    return approved;
  } catch (err) {
    console.error("Error checking approval status:", err);
    return null;
  }
};

const handleImageUpload = async (files) => {
  if (!files.length) return;

  toast.info("⏳ Uploading images to Pinata...");

  const ipfsUrls = [];

  for (const file of files) {
    try {
      const formData = new FormData();
      formData.append("file", file);

      const metadata = JSON.stringify({ name: file.name });
      formData.append("pinataMetadata", metadata);

      const options = JSON.stringify({ cidVersion: 0 });
      formData.append("pinataOptions", options);

      const res = await axios.post("https://api.pinata.cloud/pinning/pinFileToIPFS", formData, {
        maxBodyLength: "Infinity",
        headers: {
          "Content-Type": "multipart/form-data",
          pinata_api_key: PINATA_API_KEY,
          pinata_secret_api_key: PINATA_SECRET_API_KEY,
        },
      });

      const ipfsHash = res.data.IpfsHash;
      const ipfsUrl = `https://gateway.pinata.cloud/ipfs/${ipfsHash}`;
      ipfsUrls.push(ipfsUrl);

      toast.success(`Uploaded ${file.name}`);
    } catch (err) {
      console.error(`Upload failed for ${file.name}:`, err);
      toast.error(`Failed to upload ${file.name}`);
    }
  }

  if (ipfsUrls.length > 0) {
    try {
      const tx = await contract.addPropertyImages(propertyDetails.tokenId, ipfsUrls);
      await tx.wait();
      toast.success("All images saved to blockchain!");
      await getPropertyDetails(propertyDetails.tokenId);
    } catch (err) {
      console.error("Blockchain tx failed:", err);
      toast.error("Failed to save image URLs on chain.");
    }
  }
};





const fetchPendingTokens = useCallback(async () => {
  if (!contract || !isAdmin) return;

  try {
    const pendingTokens = await contract.getPendingApprovalTokens();
    const pendingDetails = await Promise.all(pendingTokens.map(async (tokenId) => {
      const details = await contract.getPropertyDetails(tokenId);
      return {
        tokenId: tokenId.toString(),
        propertyAddress: details[0] ?? "Unknown Address",
        transactionDetails: details[2] ?? "N/A",
      };
    }));
    return pendingDetails;
  } catch (error) {
    console.error("Error fetching pending tokens:", error);
    toast.error("Error loading pending approvals.");
    return [];
  }
}, [contract, isAdmin]);


const mintPropertyNFT = async (propertyAddress, transactionDetails, price) => {
  if (!contract) return toast.error("Contract not loaded yet.");
  if (!propertyAddress || !transactionDetails || price === undefined || price === null) {
      return toast.warn("Please fill in all fields.");
  }

  try {
      setLoading(true);
      const tokenId = Math.floor(Math.random() * 1000000);
      console.log("Minting Token ID:", tokenId);

      let priceString = price.toString().trim();

      let formattedPrice;
      if (priceString.includes(".") || Number(priceString) < 1000000000000000000) { 
          formattedPrice = ethers.utils.parseEther(priceString);
      } else {
          formattedPrice = ethers.BigNumber.from(priceString);
      }

      console.log("Minting Price in Wei:", formattedPrice.toString());

      const tx = await contract.mintPropertyNFT(
          tokenId,
          propertyAddress,
          transactionDetails,
          formattedPrice,
          { gasLimit: 3000000 }
      );

      await tx.wait();
      toast.success(`Token minted successfully! Token ID: ${tokenId}`);

      await fetchMintedTokens();
  } catch (error) {
      console.error("Minting Error:", error);
      toast.error("Error minting token: " + error.message);
  } finally {
      setLoading(false);
  }

  if (isAdmin) {
    const tokens = await fetchPendingTokens();
    setPendingApprovals(tokens || []);
  }  
};

  const burnNFT = async (tokenId) => {
    if (!contract) return toast.error("Contract not loaded yet.");
    if (!tokenId) return toast.warn("Please enter a valid token ID.");

    const confirm = window.confirm(`Are you sure you want to burn Token ID ${tokenId}?`);
    if (!confirm) return;

    try {
        setLoading(true);
        const tx = await contract.burn(tokenId);
        await tx.wait();
        toast.success(`Token ID: ${tokenId} burned successfully!`);

        setPropertyDetails(null);

        await fetchMintedTokens();
    } catch (error) {
        console.error("Burning Error:", error);
        toast.error("Error burning token: " + error.message);
    } finally {
        setLoading(false);
    }
};



  

const fetchMintedTokens = useCallback(async () => {
  if (!contract || !account) return;

  try {
    const tokens = await contract.getMintedTokens();

    const properties = await Promise.all(tokens.map(async (tokenId) => {
      const details = await contract.getPropertyDetails(tokenId);
      const listing = await contract.listingProperties(tokenId);
      const owner = await contract.ownerOf(tokenId);
      const imageUrls = await contract.getPropertyImages(tokenId);

      const tokenIdStr = tokenId.toString();
      const isOwner = owner.toLowerCase() === account.toLowerCase();
      const isListed = listing[1] ?? false;

      const shouldDisplay = isAdmin || isOwner || isListed;
      if (!shouldDisplay) return null;

      return {
        tokenId: tokenIdStr,
        propertyAddress: details[0] ?? "Unknown Address",
        ownershipHistory: details[1]?.toString() ?? "N/A",
        transactionDetails: details[2] ?? "No details available",
        price: listing[0].toString(),
        priceETH: ethers.utils.formatEther(listing[0]),
        forSale: isListed,
        propertyImages: imageUrls
      };
    }));

    const filtered = properties.filter(Boolean);
    console.log("Filtered Properties Fetched:", filtered);

    setAllProperties(filtered);
    setFilteredProperties(filtered);
  } catch (error) {
    console.error("Error fetching minted tokens:", error);
  }
}, [contract, account, isAdmin]);


const fetchPendingApprovals = async () => {
  const tokens = await contract.getPendingApprovalTokens();
  const approvals = await Promise.all(
    tokens.map(async (tokenId) => {
      const details = await contract.getPropertyDetails(tokenId);
      const complianceRaw = await contract.getCompliance(tokenId);
      return {
        tokenId: tokenId.toString(),
        propertyAddress: details[0],
        transactionDetails: details[2],
        compliance: {
          fireAlarmTested: complianceRaw[0],
          gasCertified: complianceRaw[1],
          electricalSafetyPassed: complianceRaw[2],
          legalApproved: complianceRaw[3],
          inspectorNotes: complianceRaw[4],
        },
      };
    })
  );
  return approvals;
};


const updateCompliance = async (tokenId) => {
  try {
    const tx = await contract.updateCompliance(
      tokenId,
      fireAlarmChecked,
      gasCertifiedChecked,
      electricalSafeChecked,
      legalApprovedChecked,
      inspectorNotes
    );
    await tx.wait();

    toast.success("Compliance updated!");

    await getPropertyDetails(tokenId);

    const updatedApprovals = await fetchPendingApprovals(); 
    setPendingApprovals(updatedApprovals);

    setFireAlarmChecked(false);
    setGasCertifiedChecked(false);
    setElectricalSafeChecked(false);
    setLegalApprovedChecked(false);
    setInspectorNotes("");
  } catch (err) {
    console.error("Error updating compliance:", err);
    toast.error("Failed to update compliance");
  }
};



const fetchOwnedNFTs = useCallback(async () => {
  if (!contract || !account) return;
  try {
    const ownedTokens = await contract.getOwnedTokens(account);
    setOwnedNFTs(ownedTokens);
    console.log("Owned NFTs fetched:", ownedTokens);
  } catch (error) {
    console.error("Error fetching owned NFTs:", error);
  }
}, [contract, account]);


const buyProperty = async (tokenId) => {
  if (!contract) return toast.error("Contract not loaded.");
  if (!tokenId) return toast.warn("Please enter a valid Token ID.");

  try {
    console.log("Clicking buy property button...");
    console.log("Token ID:", tokenId);

    const listing = await contract.listingProperties(tokenId);

    if (!listing.forSale) {
      return toast.error(" This property is NOT listed for sale.");
    }

    const priceInWei = listing.price;

    console.log(" Stored Price in Wei (from contract):", priceInWei.toString());

    if (!priceInWei || priceInWei.isZero?.()) {
      return toast.error(" Property price is zero or undefined.");
    }

    const walletBalance = await contract.provider.getBalance(account);
    console.log("Wallet balance:", walletBalance.toString());
    console.log("Sending amount in Wei:", priceInWei.toString());

    if (walletBalance.lt(priceInWei)) {
      return toast.error(" Insufficient balance to complete the purchase.");
    }

    let gasEstimate;
    try {
      gasEstimate = await contract.estimateGas.buyProperty(tokenId, {
        value: priceInWei,
      });
    } catch (gasError) {
      console.error(" Gas estimation failed:", gasError);
      return toast.error(" Gas estimation failed: " + (gasError.reason || gasError.message));
    }

    const transaction = await contract.buyProperty(tokenId, {
      value: priceInWei,
      gasLimit: gasEstimate.add(50000),
    });

    console.log(" Transaction sent. Waiting for confirmation...");
    await transaction.wait();

    toast.success(" Purchase successful!");
    console.log(" Property successfully purchased.");

    await getPropertyDetails(tokenId);
  } catch (error) {
    console.error(" Purchase failed:", error);
    toast.error(` Purchase failed: ${error.reason || error.message}`);
    console.error("Full error details:", error);
  }
};


const handleBuyProperty = async (tokenId) => {
  if (loading) return; 

  setLoading(true); 

  try {
      await buyProperty(tokenId);
      setLoading(false);
  } catch (error) {
      setLoading(false);
      console.error("Error while buying property:", error);
  }
};



const listPropertyForSale = async (tokenId) => {
  if (!contract || !propertyDetails || !propertyDetails.price) {
      console.error(" Error: Contract or price is undefined.");
      return;
  }

  const approved = await contract.approvedProperties(tokenId);
  console.log(" Is token approved?", approved);

  try {
      let rawPrice = propertyDetails.price.toString().trim();
      console.log(" Step 1: Raw Price from State (Before Conversion):", rawPrice);

      let priceInWei;
      if (ethers.BigNumber.isBigNumber(rawPrice)) {
          priceInWei = rawPrice; 
      } else if (rawPrice.includes(".") || Number(rawPrice) < 1000000000000000000) {
          priceInWei = ethers.utils.parseEther(rawPrice);
      } else {
          priceInWei = ethers.BigNumber.from(rawPrice);
      }

      console.log(" Step 2: Final Correct Price in Wei:", priceInWei.toString());

      const tx = await contract.listPropertyForSale(tokenId, priceInWei);
      await tx.wait();

      console.log(` Property ${tokenId} is now listed for sale!`);
      await getPropertyDetails(tokenId);
  } catch (error) {
      console.error(" Listing failed:", error);
      toast.error(" Listing failed: " + error.message);
  }
};



const unlistPropertyForSale = async () => {
  if (!contract) return toast.error("Contract not loaded yet.");
  if (!currentTokenId || isNaN(currentTokenId)) return toast.warn("Please enter a valid Token ID.");

  try {
    console.log("Available contract functions:", contract);
    console.log(`Unlisting Token ID ${currentTokenId} from sale...`);

    const tx = await contract.unlistProperty(currentTokenId);
    await tx.wait();

    toast.success(`Property ${currentTokenId} is now removed from sale!`);
    getPropertyDetails(currentTokenId);
  } catch (error) {
    console.error(" Unlisting Error:", error);
    toast.error(" Error removing property from sale.");
  }
};

const updatePrice = async (tokenId, newPriceInETH) => {
  if (!contract || !tokenId || !newPriceInETH) return toast.error("Missing input");
  try {
    const newPriceWei = ethers.utils.parseEther(newPriceInETH);
    const tx = await contract.updateListingPrice(tokenId, newPriceWei);
    await tx.wait();
    toast.success("Price updated!");
    await getPropertyDetails(tokenId);
  } catch (err) {
    console.error(" Error updating price:", err);
    toast.error(" Failed to update price.");
  }
};


const filterProperties = (query) => {
  if (!query) {
      setFilteredProperties(allProperties);
      return;
  }

  const lowerQuery = query.toLowerCase();
  const filtered = allProperties.filter((property) =>
      property.tokenId.toString().includes(lowerQuery) || 
      property.propertyAddress.toLowerCase().includes(lowerQuery)
  );

  setFilteredProperties(filtered);
};

const logEvent = (message) => {
  const event = {
      message,
      timestamp: new Date().toLocaleString()
  };

  setEventLogs((prevLogs) => [...prevLogs, event]);
  console.log(" New Event Logged:", event);
};



useEffect(() => {
  if (walletConnected && contract && account) {
    fetchMintedTokens();
    
    Promise.all([fetchMintedTokens(), fetchOwnedNFTs()])
      .then(() => console.log("Tokens fetched successfully!"))
      .catch((error) => console.error(" Error in useEffect fetch:", error));

    
    if (isAdmin) {
      fetchPendingTokens()
        .then((tokens) => setPendingApprovals(tokens || []))
        .catch((err) => console.error(" Error loading pending approvals:", err));
    }

   
    const interval = setInterval(() => {
      fetchMintedTokens();
      fetchOwnedNFTs();
      if (isAdmin) {
        fetchPendingTokens()
          .then((tokens) => setPendingApprovals(tokens || []))
          .catch((err) => console.error(" Poll error loading pending:", err));
      }
    }, 10000);

    
    const handlePropertyMinted = async (tokenId, owner) => {
      logEvent(` Property Minted - Token ID: ${tokenId} | Owner: ${owner}`);
      if (isAdmin) {
        const tokens = await fetchPendingTokens();
        setPendingApprovals(tokens || []);
      }
    };

    const handlePropertyTransferred = (tokenId, from, to) => {
      logEvent(`Property Transferred - Token ID: ${tokenId} | From: ${from} → To: ${to}`);
    };

    const handleTransactionRecorded = (tokenId, buyer, seller, price) => {
      logEvent(`Transaction Recorded - Token ID: ${tokenId} | Buyer: ${buyer} | Seller: ${seller} | Price: ${ethers.utils.formatEther(price)} ETH`);
    };

    const handlePropertySold = (tokenId, seller, buyer, price) => {
      logEvent(`Property Sold - Token ID: ${tokenId} | Seller: ${seller} | Buyer: ${buyer} | Price: ${ethers.utils.formatEther(price)} ETH`);
    };

    contract.on("PropertyMinted", handlePropertyMinted);
    contract.on("PropertyTransferred", handlePropertyTransferred);
    contract.on("TransactionRecorded", handleTransactionRecorded);
    contract.on("PropertySold", handlePropertySold);

    return () => {
      clearInterval(interval);
      contract.off("PropertyMinted", handlePropertyMinted);
      contract.off("PropertyTransferred", handlePropertyTransferred);
      contract.off("TransactionRecorded", handleTransactionRecorded);
      contract.off("PropertySold", handlePropertySold);
    };
  }

  console.log("Checking contract instance...", contract);
}, [walletConnected, contract, account, isAdmin, fetchMintedTokens, fetchOwnedNFTs, fetchPendingTokens]);


useEffect(() => {
  if (typeof window !== "undefined" && window.bootstrap) {
    const tooltipTriggerList = Array.from(
      document.querySelectorAll('[data-bs-toggle="tooltip"]')
    );
    tooltipTriggerList.forEach((el) => new window.bootstrap.Tooltip(el));
  } else {
    console.warn("Bootstrap not yet loaded.");
  }
}, [propertyDetails, pendingApprovals]);


return (
  <>
  <div className="container-fluid mt-5 px-5">
    <h1 className="text-center mb-4">Property NFT DApp</h1>

    <div className="text-center mb-3">
      {walletConnected ? (
        <div className="alert alert-success">
          <strong>Connected:</strong> {account || "Loading..."}{" "}
          <span className="ms-2 badge bg-primary">
            {isAdmin ? "Admin" : "User"}
          </span>
          <br />
          {ethBalance ? (
            <span className="text-muted">Balance: {ethBalance} ETH</span>
          ) : (
            "Fetching balance..."
          )}
        </div>
      ) : (
        <div className="alert alert-warning">Please connect your wallet.</div>
      )}
    </div>

    {!walletConnected && (
      <div className="text-center mb-4">
        <button className="btn btn-primary" onClick={connectWallet}>
          Connect MetaMask Wallet
        </button>
      </div>
    )}

<div className="row">
  <div className="col-lg-8">
    {walletConnected && (
      <div className="card p-4 mb-4 shadow">
        <h5 className="mb-4">Mint New Property NFT</h5>
        <div className="row g-3">
          <div className="col-md-6">
            <input
              id="propertyAddress"
              className="form-control"
              placeholder="Property Address"
            />
          </div>
          <div className="col-md-6">
            <input
              id="transactionDetails"
              className="form-control"
              placeholder="Transaction Details"
            />
          </div>
          <div className="col-md-6">
            <input
              id="propertyPrice"
              className="form-control"
              type="number"
              step="0.01"
              placeholder="Price (ETH)"
            />
          </div>
          <div className="col-md-6 d-grid">
            <button
              className="btn btn-success"
              onClick={() => {
                const address = document.getElementById("propertyAddress").value.trim();
                const details = document.getElementById("transactionDetails").value.trim();
                const priceInput = document.getElementById("propertyPrice").value.trim();

                if (!address || !details || !priceInput) {
                  return toast.warn("Please fill in all fields correctly.");
                }

                try {
                  const price = ethers.utils.parseUnits(priceInput, "ether");
                  mintPropertyNFT(address, details, price);
                } catch (error) {
                  console.error("Invalid price input:", error);
                  toast.error("Invalid price format. Enter a valid number.");
                }
              }}
            >
              {loading ? <Spinner animation="border" size="sm" /> : "Mint NFT"}
            </button>
          </div>
        </div>
      </div>
    )}

    <div className="card p-4 mb-4 shadow">
      <h5 className="mb-3">Search Properties</h5>
      <input
        type="text"
        id="searchInput"
        className="form-control"
        placeholder="Enter Token ID or Address"
        onChange={(e) => filterProperties(e.target.value)}
      />
    </div>

    <div className="card p-4 mb-4 shadow">
      <h5 className="mb-4">Available Properties</h5>

      {filteredProperties.length > 0 ? (
        <div
          className="d-flex overflow-auto gap-3 pb-2"
          style={{ scrollSnapType: "x mandatory", WebkitOverflowScrolling: "touch" }}
        >
          {filteredProperties.map((property) => (
            <div
              key={property.tokenId?.toString?.()}
              className="flex-shrink-0"
              style={{ width: "300px", scrollSnapAlign: "start" }}
            >
              <div className="card h-100 border border-primary shadow-sm">
                {property.propertyImages?.length > 0 && (
                  <img
                    src={`https://ipfs.io/ipfs/${property.propertyImages[0].split('/').pop()}`}
                    alt="Property Preview"
                    className="card-img-top"
                    style={{ height: "180px", objectFit: "cover" }}
                  />
                )}
                <div className="card-body d-flex flex-column">
                  <h6 className="card-title">Token #{property.tokenId.toString()}</h6>
                  <p className="text-muted small mb-2">{property.propertyAddress}</p>
                  <p className="mb-1"><strong>Status:</strong> {property.forSale ? "For Sale" : "Not Listed"}</p>
                  <p className="mb-3"><strong>Price:</strong> {property.priceETH} ETH</p>
                  <button
                    className="btn btn-outline-primary mt-auto"
                    onClick={() => getPropertyDetails(property.tokenId.toString())}
                  >
                    View Details
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="alert alert-warning">No properties found matching your search.</div>
      )}
    </div>


    {propertyDetails && (
      <div className="card p-4 mb-4 shadow">
        <h4 className="mb-4">Property Details</h4>

        <div className="row mb-4">
          <div className="col-md-6">
            <p><strong>Token ID:</strong> {propertyDetails.tokenId}</p>
            <p><strong>Address:</strong> {propertyDetails.propertyAddress || "N/A"}</p>
            <p><strong>Transaction Details:</strong> {propertyDetails.transactionDetails || "N/A"}</p>
            <p>
              <strong>Price:</strong> {propertyDetails.priceETH} ETH{" "}
              {propertyDetails.forSale ? (
                <span className="text-success">(For Sale)</span>
              ) : (
                <span className="text-muted">(Not for Sale)</span>
              )}
            </p>
            <p>
              <strong>Status:</strong>{" "}
              {propertyDetails.approved ? (
                <span className="badge bg-success">Approved</span>
              ) : (
                <span className="badge bg-warning text-dark">Pending Approval</span>
              )}
            </p>
          </div>

          <div className="col-md-6">
            <h6>Ownership History</h6>
            <ul className="list-group mb-3">
              {propertyDetails.ownershipHistory.length > 0 ? (
                propertyDetails.ownershipHistory.map((owner, index) => (
                  <li key={index} className="list-group-item small">{owner}</li>
                ))
              ) : (
                <li className="list-group-item text-muted">No previous owners.</li>
              )}
            </ul>
          </div>
        </div>

        {account?.toLowerCase() === propertyDetails.currentOwner?.toLowerCase() && (
          <>
            {propertyDetails.forSale && (
              <div className="card p-3 shadow-sm mb-3">
                <h6>Update Price</h6>
                <div className="input-group">
                  <input
                    type="number"
                    step="0.01"
                    min="0"
                    placeholder="New price in ETH"
                    className="form-control"
                    value={newPrice}
                    onChange={(e) => setNewPrice(e.target.value)}
                  />
                  <button
                    className="btn btn-outline-primary"
                    onClick={() => updatePrice(propertyDetails.tokenId, newPrice)}
                  >
                    Save
                  </button>
                </div>
              </div>
            )}

            <div className="card p-3 shadow-sm mb-3">
              <h6>Upload Property Images</h6>
              <input
                type="file"
                multiple
                accept="image/*"
                onChange={(e) => handleImageUpload(e.target.files)}
                className="form-control"
              />
            </div>

            {!propertyDetails.forSale ? (
              <button
                onClick={() => listPropertyForSale(propertyDetails.tokenId)}
                className="btn btn-success w-100 mb-3"
              >
                List Property for Sale
              </button>
            ) : (
              <button
                onClick={() => unlistPropertyForSale(propertyDetails.tokenId)}
                className="btn btn-warning w-100 mb-3"
              >
                Unlist Property
              </button>
            )}

            <div className="card p-3 shadow-sm border border-danger">
              <h6 className="text-danger">Burn This NFT</h6>
              <p className="text-muted small">
                Permanently destroy this NFT. This action is irreversible.
              </p>
              <button
                className="btn btn-danger"
                onClick={() => burnNFT(propertyDetails.tokenId)}
              >
                Burn NFT
              </button>
            </div>
          </>
        )}

        {propertyDetails.forSale &&
          account?.toLowerCase() !== propertyDetails.currentOwner?.toLowerCase() && (
            <div className="card p-3 shadow-sm mb-3">
              <h6>Secure Property Purchase</h6>
              <button
                onClick={() => handleBuyProperty(propertyDetails.tokenId)}
                className="btn btn-primary w-100"
                disabled={loading}
              >
                {loading ? "Processing..." : "Buy Property"}
              </button>
            </div>
          )}

        {propertyDetails.propertyImages?.length > 0 && (
          <div className="mb-4">
            <h5>Property Gallery</h5>

            {!galleryExpanded && (
              <div
                style={{
                  display: "flex",
                  gap: "8px",
                  overflowX: "auto",
                  cursor: "pointer"
                }}
                onClick={() => setGalleryExpanded(true)}
              >
                {propertyDetails.propertyImages.map((url, index) => (
                  <img
                    key={index}
                    src={url}
                    alt={`Property Thumb ${index + 1}`}
                    style={{
                      height: "100px",
                      width: "auto",
                      borderRadius: "4px",
                      flexShrink: 0
                    }}
                  />
                ))}
              </div>
            )}

            {galleryExpanded && (
              <div
                style={{
                  position: "relative",
                  zIndex: 5,
                  background: "white",
                  padding: "1rem",
                  boxShadow: "0 0 10px rgba(0,0,0,0.2)",
                  marginTop: "1rem"
                }}
              >
                <button
                  className="btn btn-secondary btn-sm mb-2"
                  onClick={() => setGalleryExpanded(false)}
                >
                  Close Gallery
                </button>

                <Carousel
                  showThumbs={true}
                  infiniteLoop={true}
                  useKeyboardArrows={true}
                  dynamicHeight={true}
                >
                  {propertyDetails.propertyImages.map((url, index) => (
                    <div key={index}>
                      <img
                        src={url}
                        alt={`Property ${index + 1}`}
                        style={{
                          maxHeight: "500px",
                          objectFit: "contain",
                          borderRadius: "8px"
                        }}
                      />
                    </div>
                  ))}
                </Carousel>
              </div>
            )}
          </div>
        )}


        <div className="row">
          {propertyDetails.compliance && (
            <div className="col-md-6 mt-4">
              <h5>Compliance Checklist</h5>
              <ul className="list-group">
                <li className="list-group-item">
                  Fire Alarm Tested: {propertyDetails.compliance.fireAlarmTested ? "Yes" : "No"}
                </li>
                <li className="list-group-item">
                  Gas Certified: {propertyDetails.compliance.gasCertified ? "Yes" : "No"}
                </li>
                <li className="list-group-item">
                  Electrical Safety Passed: {propertyDetails.compliance.electricalSafetyPassed ? "Yes" : "No"}
                </li>
                <li className="list-group-item">
                  Legal Approved: {propertyDetails.compliance.legalApproved ? "Yes" : "No"}
                </li>
                <li className="list-group-item">
                  Inspector Notes: {propertyDetails.compliance.inspectorNotes}
                </li>
              </ul>
            </div>
          )}

          {propertyDetails.analytics && (
            <div className="col-md-6 mt-4">
              <h5>Sale Analytics</h5>
              <ul className="list-group">
                <li className="list-group-item">Total Sales: {propertyDetails.analytics.totalSales}</li>
                <li className="list-group-item">Highest Sale Price: {propertyDetails.analytics.highestSalePrice} ETH</li>
              </ul>
            </div>
          )}
        </div>
      </div>
    )}




    <div className="card p-4 mb-4 shadow">
      <h4 className="mb-4">Your Owned Properties</h4>

      {ownedNFTs.length > 0 ? (
        <div className="row g-4">
          {ownedNFTs.map((tokenId) => (
            <div className="col-sm-6 col-lg-4" key={tokenId.toString()}>
              <div className="card h-100 border border-primary shadow-sm">
                <div className="card-body d-flex flex-column">
                  <h6 className="card-title">Token #{tokenId.toString()}</h6>
                  <p className="text-muted small mb-3">This NFT represents a property you own.</p>
                  <button
                    className="btn btn-outline-primary mt-auto"
                    onClick={() => getPropertyDetails(tokenId.toString())}
                  >
                    View Details
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <p className="text-muted">You don’t own any property NFTs yet.</p>
      )}
    </div>
  </div>

  <div className="col-lg-4">
    {isAdmin && (
      <div className="card p-4 mb-4 shadow">
        <h4 className="mb-4">Pending Property Approvals</h4>

        {pendingApprovals.length === 0 ? (
          <p className="text-muted">No pending approvals.</p>
        ) : (
          <div className="d-flex flex-column gap-4">
            {pendingApprovals.map((property) => {
              const checklist = property.compliance || {};
              const tokenId = property.tokenId?.toString?.() || "";

              const isCompliant =
                checklist.fireAlarmTested &&
                checklist.gasCertified &&
                checklist.electricalSafetyPassed &&
                checklist.legalApproved;

              return (
                <div key={tokenId} className="card p-3 border-light shadow-sm">
                  <div className="row g-4">
                    <div className="col-lg-6">
                      <p><strong>ID:</strong> {tokenId}</p>
                      <p><strong>Address:</strong> {property.propertyAddress}</p>
                      <p><strong>Details:</strong> {property.transactionDetails}</p>

                      <h6 className="mt-3">Compliance Checklist</h6>
                      <ul className="list-group small">
                        <li className="list-group-item">Fire Alarm Tested: {checklist.fireAlarmTested ? "Yes" : "No"}</li>
                        <li className="list-group-item">Gas Certified: {checklist.gasCertified ? "Yes" : "No"}</li>
                        <li className="list-group-item">Electrical Safety Passed: {checklist.electricalSafetyPassed ? "Yes" : "No"}</li>
                        <li className="list-group-item">Legal Approved: {checklist.legalApproved ? "Yes" : "No"}</li>
                        <li className="list-group-item">Inspector Notes: {checklist.inspectorNotes || "None"}</li>
                      </ul>
                    </div>

                    <div className="col-lg-6">
                      <div className="card p-3 h-100">
                        <h6 className="mb-3">Update Compliance</h6>
                        {[
                          ["fireAlarmChecked", "Fire Alarm Tested", fireAlarmChecked, setFireAlarmChecked],
                          ["gasCertifiedChecked", "Gas Certified", gasCertifiedChecked, setGasCertifiedChecked],
                          ["electricalSafeChecked", "Electrical Safety Passed", electricalSafeChecked, setElectricalSafeChecked],
                          ["legalApprovedChecked", "Legal Approval", legalApprovedChecked, setLegalApprovedChecked]
                        ].map(([id, label, checked, setter]) => (
                          <div className="form-check" key={id}>
                            <input
                              type="checkbox"
                              className="form-check-input"
                              id={id}
                              checked={checked}
                              onChange={() => setter(!checked)}
                            />
                            <label className="form-check-label" htmlFor={id}>{label}</label>
                          </div>
                        ))}

                        <div className="form-group mt-3">
                          <label>Inspector Notes:</label>
                          <textarea
                            className="form-control"
                            rows={2}
                            value={inspectorNotes}
                            onChange={(e) => setInspectorNotes(e.target.value)}
                          />
                        </div>

                        <button
                          onClick={() => updateCompliance(tokenId)}
                          className="btn btn-primary mt-3"
                        >
                          Save Compliance
                        </button>

                        <div className="mt-4 d-flex flex-wrap gap-2">
                          <button
                            className="btn btn-success"
                            onClick={() => approveProperty(tokenId)}
                            disabled={!isCompliant}
                          >
                            Approve
                          </button>

                          <button
                            className="btn btn-outline-danger"
                            onClick={() => rejectProperty(tokenId)}
                          >
                            Reject
                          </button>

                          <button
                            className="btn btn-outline-info"
                            onClick={() => getPropertyDetails(tokenId)}
                          >
                            View Details
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    )}
  </div>
</div>


  
<footer className="text-center mt-5 pt-4 border-top">
  <p className="text-muted small mb-0">
    &copy; {new Date().getFullYear()} Property NFT DApp. All rights reserved.
  </p>
</footer>

<div className="text-center my-4">
  <button 
    className="btn btn-outline-secondary"
    onClick={() => setShowEventLogs(!showEventLogs)}
  >
    {showEventLogs ? "Hide Event Logs" : "Show Event Logs"}
  </button>
</div>

{showEventLogs && (
  <div className="card p-4 mb-4 shadow-sm">
    <h5 className="mb-3">Event Logs</h5>
    <div className="log-box" style={{ maxHeight: "300px", overflowY: "auto" }}>
      <ul className="list-group">
        {eventLogs.length > 0 ? (
          eventLogs.map((log, index) => (
            <li key={index} className="list-group-item small">
              <strong>{log.timestamp}</strong> – {log.message}
            </li>
          ))
        ) : (
          <li className="list-group-item text-muted">No events recorded yet.</li>
        )}
      </ul>
    </div>
  </div>
)}


<ToastContainer position="bottom-right" theme="colored" />
  </div> 
</>     
);


}

export default App;