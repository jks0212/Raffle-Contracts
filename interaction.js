const ethers = require("ethers");
require("dotenv").config();

const provider = new ethers.providers.JsonRpcProvider(
  process.env.GOERLI_ALCHEMY_API
);

const fs = require("fs");
const path = require("path");

const getTheAbi = () => {
  try {
    const dir = path.resolve(
      __dirname,
      "./artifacts/contracts/Raffle.sol/Raffle.json"
    );
    const file = fs.readFileSync(dir, "utf8");
    const json = JSON.parse(file);
    const abi = json.abi;
    // console.log(`abi`, abi);

    return abi;
  } catch (e) {
    console.log(`e`, e);
  }
};

const contractAddress = "0xC8d3F2eC8a3F1929d4F172c25fa4bFA62E4f5C3E";
const contract = new ethers.Contract(contractAddress, getTheAbi(), provider);

contract.getListingFee().then(console.log);
