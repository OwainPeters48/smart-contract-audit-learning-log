const { ethers } = require("hardhat");

describe("Gas Usage: PropertyNFT Contract", function () {
  let propertyNFT, owner, user;

  before(async function () {
    [owner, user] = await ethers.getSigners();

    const CreateLibraryFactory = await ethers.getContractFactory("CreateLibrary");
    const createLibrary = await CreateLibraryFactory.deploy();
    await createLibrary.waitForDeployment();

    const GetterLibraryFactory = await ethers.getContractFactory("GetterLibrary");
    const getterLibrary = await GetterLibraryFactory.deploy();
    await getterLibrary.waitForDeployment();

    const PropertyNFT = await ethers.getContractFactory("PropertyNFT", {
      libraries: {
        CreateLibrary: await createLibrary.getAddress(),
        GetterLibrary: await getterLibrary.getAddress()
      },
    });

    propertyNFT = await PropertyNFT.deploy();
    await propertyNFT.waitForDeployment();
  });

  it("should measure gas for mintPropertyNFT", async function () {
    const tx = await propertyNFT.mintPropertyNFT(
      1,
      "14a Trafalgar Place, Swansea",
      "Detached house, 4 bedrooms with ensuites",
      ethers.parseEther("1")
    );
    const receipt = await tx.wait();
    console.log("Gas used for mintPropertyNFT:", receipt.gasUsed.toString());
  });

  it("should measure gas for addPropertyImages", async function () {
    const images = [
      "https://gateway.pinata.cloud/ipfs/Image1",
      "https://gateway.pinata.cloud/ipfs/Image2"
    ];
    const tx = await propertyNFT.addPropertyImages(1, images);
    const receipt = await tx.wait();
    console.log("Gas used for addPropertyImages:", receipt.gasUsed.toString());
  });

  it("should measure gas for listPropertyForSale and buyProperty", async function () {
    const tokenId = 1;

    await propertyNFT.approveProperty(tokenId);

    await propertyNFT.listPropertyForSale(tokenId, ethers.parseEther("1"));

    const tx = await propertyNFT.connect(user).buyProperty(tokenId, {
      value: ethers.parseEther("1")
    });

    const receipt = await tx.wait();
    console.log("Gas used for buyProperty:", receipt.gasUsed.toString());
  });

  it("should measure gas for burn", async function () {
    const tx = await propertyNFT.burn(1);
    const receipt = await tx.wait();
    console.log("Gas used for burn:", receipt.gasUsed.toString());
  });
});
