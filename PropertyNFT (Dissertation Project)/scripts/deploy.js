const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log(`Deploying contracts with account: ${deployer.address}`);

  // Deploy AnalyticsLibrary
  console.log("Deploying AnalyticsLibrary...");
  const AnalyticsLibrary = await hre.ethers.getContractFactory("AnalyticsLibrary");
  const analyticsLibrary = await AnalyticsLibrary.deploy();
  await analyticsLibrary.waitForDeployment();
  const analyticsLibraryAddress = await analyticsLibrary.getAddress();
  console.log(`AnalyticsLibrary deployed at: ${analyticsLibraryAddress}`);

  // Deploy CreateLibrary
  console.log("Deploying CreateLibrary...");
  const CreateLibrary = await hre.ethers.getContractFactory("CreateLibrary");
  const createLibrary = await CreateLibrary.deploy();
  await createLibrary.waitForDeployment();
  const createLibraryAddress = await createLibrary.getAddress();
  console.log(`CreateLibrary deployed at: ${createLibraryAddress}`);

  // Deploy GetterLibrary
  console.log("Deploying GetterLibrary...");
  const GetterLibrary = await hre.ethers.getContractFactory("GetterLibrary");
  const getterLibrary = await GetterLibrary.deploy();
  await getterLibrary.waitForDeployment();
  const getterLibraryAddress = await getterLibrary.getAddress();
  console.log(`GetterLibrary deployed at: ${getterLibraryAddress}`);

  // Deploy PropertyNFT
  console.log("Deploying PropertyNFT...");
  const PropertyNFT = await hre.ethers.getContractFactory("PropertyNFT", {
    libraries: {
      CreateLibrary: createLibraryAddress,
      GetterLibrary: getterLibraryAddress,
    },
  });

  const propertyNFT = await PropertyNFT.deploy();
  await propertyNFT.waitForDeployment();
  const propertyNFTAddress = await propertyNFT.getAddress();
  console.log(`PropertyNFT deployed at: ${propertyNFTAddress}`);

  // Grant ADMIN_ROLE
  console.log("Granting ADMIN_ROLE to deployer...");
  const ADMIN_ROLE = hre.ethers.keccak256(hre.ethers.toUtf8Bytes("ADMIN_ROLE"));
  const tx = await propertyNFT.grantRole(ADMIN_ROLE, deployer.address);
  await tx.wait();
  console.log(`ADMIN_ROLE granted to deployer: ${deployer.address}`);

  console.log("Deployment complete!");
}

main().catch((error) => {
  console.error("Error during deployment:", error);
  process.exitCode = 1;
});
