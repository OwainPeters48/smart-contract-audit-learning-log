# PropertyNFT Smart Contract Backend

This repository contains the smart contracts and deployment logic for the PropertyNFT project, which enables blockchain-based property transactions using ERC-721 NFTs. Properties can be minted, listed, and transferred on the Ethereum blockchain, with metadata stored on IPFS.

---

## Project Structure

```
/contracts/         Solidity smart contracts (PropertyNFT and libraries)
/scripts/           Hardhat deployment scripts
/test/              Unit tests for smart contracts
hardhat.config.js   Hardhat configuration
.env.example        Environment variables
```

---

## Requirements

- Node.js and npm
- Hardhat
- MetaMask
- Alchemy or Infura RPC URL for Sepolia Testnet

---

## Setup Instructions

### 1. Install dependencies

```bash
npm install
```

### 2. Configure Environment Variables

Create a `.env` file in the root directory based on `.env.example`:

```env
PRIVATE_KEY=your_wallet_private_key
ALCHEMY_API_URL=https://sepolia.infura.io/v3/your_project_id
ETHERSCAN_API_KEY=your_etherscan_key
```

### Compile & Deploy Contracts

### Compile the contracts

```bash
npx hardhat compile
```

### Deploy to Sepolia Testnet

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

### Deploy to localhost (Hardhat node)

```bash
npx hardhat node
npx hardhat run scripts/deploy.js --network localhost
```
---

## Run Tests

To run the smart contract unit tests:

```bash
npx hardhat test
```

  Includes tests for minting, transferring, and retrieving property data.

---

## Key Contracts

- `PropertyNFT.sol`: ERC-721 property NFT contract handling minting, listing, ownership transfer, and metadata storage
- `CreateLibrary.sol`: Manages transaction logs, maintenance records, and compliance types for each property
- `GetterLibrary.sol`: Provides view functions to fetch detailed property, transaction, and ownership data
- `AnalyticsLibrary.sol`: Contains functions for calculating analytics such as sales volume, average property value, etc.

---

## Notes

- Ensure contract addresses are copied to your frontend config after deployment
- ABI files are generated automatically in the `artifacts/` folder after compilation

---

## License

MIT – for academic use only.