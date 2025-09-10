require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { PRIVATE_KEY, ALCHEMY_API_URL } = process.env;

if (!PRIVATE_KEY || !ALCHEMY_API_URL) {
  throw new Error("Missing environment variables: Ensure PRIVATE_KEY and ALCHEMY_API_URL are set.");
}

module.exports = {
  solidity: {
    version: "0.8.27",
    settings: {
      optimizer: {
        enabled: true,
        runs: 100,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
      timeout: 200000,
    },
    sepolia: {
      url: ALCHEMY_API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
      verify: {
        libraries: {
          CreateLibrary: "0DeployedAddress",
          GetterLibrary: "0xDeployedAddress",
          AnalyticsLibrary: "0xDeployedAddress",
        },
      },
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  etherscan: {
    apiKey: {
      sepolia: "ETHERSCAN_API_KEY",
    },
  },
  sourcify: {
    enabled: false,
  },
};
