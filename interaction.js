const ethers = require("ethers");
require("dotenv").config();

const privateKey =
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

// const providerAddress = process.env.GOERLI_ALCHEMY_API;
const providerAddress = "http://127.0.0.1:8545";

const raffleManagerContractAddress =
  "0xe7f1725e7734ce288f8367e1bb143e90bb3f0512";

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

// const contract = new ethers.Contract(address, abi, provider);
// const unsignedTx = await contract.populateTransaction.approve(spender, amount);

// const wallet = new ethers.Wallet("0xprivatekey");
// const signedTx = await wallet.signTransaction(unsignedTx);

// // at a later point in Time
// await provider.submitTransaction(signedTx);

const wallet = new ethers.Wallet(privateKey, provider);
const contract = new ethers.Contract(
  raffleManagerContractAddress,
  getRaffleManagerAbi(),
  wallet
);

contract.connect(wallet);

contract.getRaffles().then(console.log);

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

