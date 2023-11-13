// Load necessary plugins and libraries
require('dotenv').config(); // Load environment variables from .env
const { HardhatUserConfig } = require("hardhat/config");
require("@nomicfoundation/hardhat-toolbox");

// Define network configurations
const networks = {
  localhost: {
    url: 'http://127.0.0.1:8545',
    accounts: [process.env.LOCAL_PK], // Use the private key from .env
  },
  anvil: {
    url: '127.0.0.1:8545',
    accounts: [process.env.ANVIL_PK]
  },
  sepolia: {
    url: 'https://eth-sepolia.g.alchemy.com/v2/demo',
    accounts: [process.env.LIVE_PK],
  },
};

// Define path configurations
const paths = {
  artifacts: './build/artifacts',
  cache: './build/cache'
};

// Export the Hardhat configuration
const config = {
  solidity: "0.8.17",
  networks,
  paths
};

module.exports = config;
