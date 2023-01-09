const ethers = require("ethers");
const web3 = require("web3");
require("dotenv").config();

// const privateKey =
//   "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
const privateKey = process.env.PRIVATE_KEY;

const providerAddress = process.env.GOERLI_ALCHEMY_API;
// const providerAddress = "http://127.0.0.1:8545";

const raffleManagerContractAddress =
  "0x583603619088aFfAeE755aF2B5E208af0Ede7914";

const provider = new ethers.providers.JsonRpcProvider(providerAddress);

const fs = require("fs");
const path = require("path");

const getRaffleManagerAbi = () => {
  try {
    const dir = path.resolve(
      __dirname,
      "./artifacts/contracts/RaffleManager.sol/RaffleManager.json"
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

const wallet = new ethers.Wallet(privateKey, provider);
const contract = new ethers.Contract(
  raffleManagerContractAddress,
  getRaffleManagerAbi(),
  wallet
);

contract.connect(wallet);

// contract.getRafflesByIndex(0, 10).then(console.log);
// const r = contract.getRafflesByIndex(0, 10).json();

// console.log(r);

// contract.createRaffle(1, 2, 3, 4).then((a) => {
//   a.wait().then((b) => {
//     console.log(b.events);
//   })
// })

// .then((a, b) => {
//   console.log(a);
//   console.log("------------");
//   a.wait().then(console.log);
// });

