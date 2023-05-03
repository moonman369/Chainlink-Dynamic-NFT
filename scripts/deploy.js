const { ethers } = require("hardhat");

const deployChicBox = async (
  deployerAddress,
  upkeepInterval,
  levelUpInterval,
  maxSupply
) => {
  const deployer = await ethers.getSigner(deployerAddress);

  const contractFactory = await ethers.getContractFactory("ChicBoxNFT");

  const contractInstance = await contractFactory
    .connect(deployer)
    .deploy(upkeepInterval, levelUpInterval, maxSupply);

  await contractInstance.deployed();

  console.log(
    `ChicBoxNFT contract has been deployed at address: ${contractInstance.address}`
  );
};

const main = async () => {
  const [deployer] = await ethers.getSigners();

  await deployChicBox(deployer.address, 300, 10 * 60, 100);
};

main()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => console.error(error));

//  Deploys: {
//   1: 0x120EA1395144737693710c9Ed8eF390ba5C64b19
//   2: 0xc97d32FBd95fEd8A368502f84cAffeE793f655De => current
// }
