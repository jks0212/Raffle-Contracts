# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```

```useful commands
npx hardhat compile
npx hardhat run --network goerli .\scripts\deploy.js
npx hardhat verify --constructor-args arguments.js --network goerli "contract address"
npx hardhat run interaction.js
```

Add .env file to the root directory
```
PRIVATE_KEY = "Private key"
ACCOUNT_ADDRESS = "Account address"
ETHERSCAN_API = "Etherscan.io API key"
GOERLI_ALCHEMY_API = "Alchemy Goerli API key"
```