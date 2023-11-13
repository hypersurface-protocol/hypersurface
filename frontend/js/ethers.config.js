import dotenv from 'dotenv';
import { ethers } from 'ethers';

dotenv.config();

// Set up the provider and log network details for debugging
const provider = new ethers.providers.JsonRpcProvider("https://eth-sepolia.g.alchemy.com/v2/demo");
provider.getNetwork().then(network => {
    console.log("Connected to network:", network.name, "with chainId:", network.chainId);
}).catch(error => {
    console.error("Error fetching network details:", error);
});

const walletPrivateKey = process.env.PRIVATE_KEY;
const contractAddress = process.env.CONTRACT_ADDRESS;

// Validate that the private key and contract address are not undefined
if (!walletPrivateKey) {
    console.error("Private key is not set in the environment variables.");
}
if (!contractAddress) {
    console.error("Contract address is not set in the environment variables.");
}

// Log the contract address for debugging
console.log("Using contract address:", contractAddress);

const wallet = new ethers.Wallet(walletPrivateKey, provider);

const contractABI = [
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_detailsLibrary",
          "type": "address"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "inputs": [],
      "name": "detailsLibrary",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "fetchDetails",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        },
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_detailsLibrary",
          "type": "address"
        }
      ],
      "name": "setDetailsLibrary",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "_name",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "_email",
          "type": "string"
        },
        {
          "internalType": "uint256",
          "name": "_age",
          "type": "uint256"
        }
      ],
      "name": "updateDetails",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    }
  ];

const contract = new ethers.Contract(contractAddress, contractABI, wallet);

// Log contract details for debugging
contract.deployed().then(() => {
    console.log("Contract is deployed and accessible.");
}).catch(error => {
    console.error("Error accessing the contract:", error);
});

export {
    provider,
    wallet,
    contract
};
