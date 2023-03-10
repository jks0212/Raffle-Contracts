const hre = require("hardhat");
require("dotenv").config();

async function main() {
  const raffle = await hre.ethers.getContractFactory("Raffle");
  const raffleDeploy = await raffle.deploy(process.env.ACCOUNT_ADDRESS);

  await raffleDeploy.deployed();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
