const { ethers } = require("hardhat");

const { deployChicBox, deployChicToken } = require("./deployFunctions");

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
  const VRF_COO = "0x2ed832ba664535e5886b75d64c46eb9a228c2610"; // mumbai
  const SUB_ID = 658;

  const CALL_BACK_GAS = "2500000";
  const UPKEEP_INTERVAL = 60;
  const LEVEL_UP_INTERVAL = 60;
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
// ChicToken contract has been deployed at address: 0xABf4F42D65a4BE05BFDF406d95D408802FdC394c
// ChicBoxNFT contract has been deployed at address: 0x719F77C2265b39C93F6fbe20F7Ce665e2A9bf614
// Avax
// ChicToken contract has been deployed at address: 0xb33Fb5c119ce969Fec1b1735b4fFDC129498b134
// ChicBoxNFT contract has been deployed at address: 0x085d4E65D451fD35DE42c124c4C47d373b42cfA8
