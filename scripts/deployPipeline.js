const { ethers } = require("hardhat");

const deployChicToken = async (
  deployerAddress,
  totalSupplyExclDecimal,
  mintAddress
) => {
  const deployer = await ethers.getSigner(deployerAddress);

  const ChicToken = await ethers.getContractFactory("ChicToken");

  const chicToken = await ChicToken.connect(deployer).deploy(
    totalSupplyExclDecimal,
    mintAddress
  );

  await chicToken.deployed();

  console.log(
    `ChicToken contract has been deployed at address: ${chicToken.address}`
  );

  return chicToken;
};

const deployChicBox = async (
  deployerAddress,
  vrfCoordinatorV2,
  subscriptionId,
  gasLane,
  callbackGasLimit,
  upkeepInterval,
  levelUpInterval,
  maxSupply,
  chicTokenAddress
) => {
  const deployer = await ethers.getSigner(deployerAddress);

  const ChicBoxNFT = await ethers.getContractFactory("ChicBoxNFT");

  const chicBoxNFT = await ChicBoxNFT.connect(deployer).deploy(
    vrfCoordinatorV2,
    subscriptionId,
    gasLane,
    callbackGasLimit,
    upkeepInterval,
    levelUpInterval,
    maxSupply,
    chicTokenAddress
  );

  await chicBoxNFT.deployed();

  console.log(
    `ChicBoxNFT contract has been deployed at address: ${chicBoxNFT.address}`
  );

  return chicBoxNFT;
};

const main = async () => {
  const [deployer] = await ethers.getSigners();

  const CHIC_TOTAL_SUPPLY = 1000000000;
  const MINT_ADDRESS = deployer.address;

  const chicToken = await deployChicToken(
    deployer.address,
    CHIC_TOTAL_SUPPLY,
    MINT_ADDRESS
  );

  const GAS_LANE =
    "0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61";
  const VRF_COO = "0x2ed832ba664535e5886b75d64c46eb9a228c2610";
  const SUB_ID = 658;
  const CALL_BACK_GAS = "2500000";
  const UPKEEP_INTERVAL = 5 * 60;
  const LEVEL_UP_INTERVAL = 10 * 60;
  const MAX_SUPPLY = 100;

  await deployChicBox(
    deployer.address,
    VRF_COO,
    SUB_ID,
    GAS_LANE,
    CALL_BACK_GAS,
    UPKEEP_INTERVAL,
    LEVEL_UP_INTERVAL,
    MAX_SUPPLY,
    chicToken.address
  );
};

main()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => console.error(error));

//  Deploys: {
//   1: 0x120EA1395144737693710c9Ed8eF390ba5C64b19
//   2: 0xc97d32FBd95fEd8A368502f84cAffeE793f655De
//   3: 0xABf4F42D65a4BE05BFDF406d95D408802FdC394c => current
// }

// Sepolia
// ChicToken contract has been deployed at address: 0xBB622721B4E88C59443Aa445A96456BaF00b4a8c
// ChicBoxNFT contract has been deployed at address: 0x24C11d6d347DE57Bb435FFd66Ec7ECb960F11593

// Mumbai
// ChicToken contract has been deployed at address: 0xeD5F7D3B8bDe22c8dCcAcEF86ADBc25948BEa4e7
// ChicBoxNFT contract has been deployed at address: 0x14b41B03c2B7a90317bC4AA0E24666B4Cf2b7C58

// Avax
// ChicToken contract has been deployed at address: 0xc02ECbBfE5498A1C46b6e4aBd08cC1394Cb0418b
// ChicBoxNFT contract has been deployed at address: 0xD68646C2655df4750fDDD8bF4306444AE2a9cACb
