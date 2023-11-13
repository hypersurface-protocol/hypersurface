// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IHyperserver {


    struct Details {
        uint256 amount;
        uint256 nonce;  // Nonce, use the nonce for the total tokens?
        bytes32[][] route; // Transfer multidim-array, [] is the transfer, [][] is the route 
    }

    struct Transfer {
        address server;     // The server where the details are stored
        bytes32 tokenHash;  // The hash of the entry to be looked up
        Details details;
        bytes sig;  // The signed data
        uint8 path; // route[] index
        uint8 step; // route[][] index
    }

    function POST(IHyperserver.Transfer memory transfer) external returns (bytes memory);

    function GET(IHyperserver.Transfer memory transfer) external returns (bytes memory);
}