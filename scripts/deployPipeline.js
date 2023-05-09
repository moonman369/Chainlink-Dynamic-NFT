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
    `ChicBoxNFT contract has been deployed at address: ${chicToken.address}`
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
    "0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c";
  const VRF_COO = "0x8103b0a8a00be2ddc778e6e7eaa21791cd364625";
  const SUB_ID = 1009;
  const CALL_BACK_GAS = "2500000";
  const UPKEEP_INTERVAL = 10;
  const LEVEL_UP_INTERVAL = 30;
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
