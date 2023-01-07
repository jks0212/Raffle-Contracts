const hre = require("hardhat");
require("dotenv").config();

async function main() {
  const raffle = await hre.ethers.getContractFactory("RaffleManager");
  // const raffleDeploy = await raffle.deploy(process.env.ACCOUNT_ADDRESS);
  const raffleDeploy = await raffle.deploy();

  await raffleDeploy.deployed();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
