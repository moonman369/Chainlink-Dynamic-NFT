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

module.exports = {
  deployChicBox,
  deployChicToken,
};
