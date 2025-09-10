# PropertyNFT Frontend – React & ethers Interface

This is the React-based frontend for the PropertyNFT System. It interacts with the deployed smart contracts on the Ethereum Sepolia Testnet, allowing users to mint, view, and transfer property NFTs. Metadata and images are stored using IPFS via Pinata.

---

## Frontend Project Structure

```
my-app/
├── src/
│   ├── App.js                  Main React component
│   ├── abis/                   ABI files for contract interaction
│   └── helpers/ or utils/      Ethers interaction functions
├── .env.example                Environment variables
├── package.json                Project dependencies
```

---

## Requirements

- Node.js and npm
- MetaMask browser extension

---

## Setup Instructions

### 1. Navigate to frontend directory

```bash
cd my-app
```

### 2. Install dependencies

```bash
npm install
```

### 3. Configure environment variables

Create a `.env` file in `my-app/` based on `.env.example`:

```env
REACT_APP_PINATA_API_KEY=your_pinata_api_key
REACT_APP_PINATA_SECRET_KEY=your_pinata_secret
REACT_APP_CONTRACT_ADDRESS=your_deployed_contract_address
```

---

## Run the Frontend

```bash
npm start
```

Visit `http://localhost:3000` in your browser.

The interface allows:
- Minting new properties as NFTs
- Viewing and filtering property listings
- Displaying IPFS-stored metadata and images
- Transferring ownership via blockchain

---

## Files

- `/src/App.js`: Main frontend logic using React and Web3
- `/src/PropertyNFT.json`: ABI used to interact with the deployed contract
- `.env.example`: Defines required Pinata and contract address environment variables

---

## Notes

- Ensure contract is deployed before running the frontend
- Match the deployed contract address with `REACT_APP_CONTRACT_ADDRESS` in `.env`
- ABI file must match the deployed contract version

---

## License

MIT – for academic use only.
