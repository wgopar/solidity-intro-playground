require("@nomiclabs/hardhat-ethers");
require('hardhat-contract-sizer');
require("hardhat-deploy")
require('dotenv').config()

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "Your etherscan API key"

const networkConfig = {
    default: {
        name: 'hardhat',
        live: true
    },
    31337: {
        name: 'localhost',
    },
    4: {
        name: 'rinkeby',
    },
    1: {
        name: 'mainnet',
    }
}

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    //rinkeby: {
    //  accounts: {}
    //}
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  },
  defaultNetwork: "hardhat",
  namedAccounts: {
    deployer: {
      default: 0,
    }
  },
  solidity: "0.8.0",
};
