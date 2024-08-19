require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomicfoundation/hardhat-ethers");
require("dotenv").config();
/** @type import('hardhat/config').HardhatUserConfig */
//Defining tasks that are accessed or executed from scripts or tests
task("deploy-contract", async () => {
  const deployContract = require("./Script/DeployDonations");
  return deployContract();
});
module.exports = {
  mocha: {
    timeout:  40000,
    },
  solidity: "0.8.12",
  settings: {
    optimizer: {
        enabled: true,
        runs: 500,
  },
  },
  //Doing the Network Configurations, which networks to be used by default by hardhat
  defaultNetwork: "testnet",
  networks: {
      //Configuration settings for connecting to Hedera testnet
    testnet: {
    url: process.env.TESTNET_ENDPOINT,
    //Your ECDSA testnet acc pk pulled from the .env
    accounts: [process.env.TESTNET_OPERATOR_PRIVATE_KEY],
    },
  //   mainnet: {
    //     // HashIO mainnet endpoint from the MAINNET_ENDPOINT variable in the .env file
    //     url: process.env.MAINNET_ENDPOINT,
    //     // Your ECDSA account private key pulled from the .env file
    //     accounts: [process.env.MAINNET_OPERATOR_PRIVATE_KEY],
    // },
  },
};
