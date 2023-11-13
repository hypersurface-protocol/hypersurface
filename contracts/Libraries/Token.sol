// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IHyperserver.sol";
import "./Ledger.sol";

library Token {

    /////////////////
    // VARIABLES
    /////////////////

    struct Details {
        uint256 totalSupply;
        uint256 required;
    }

    struct TokenStorage {
        Details details;
        mapping(address => uint256) balances;
        mapping(address => uint256) nonces; // Records tx nonce of key
        mapping(address => mapping(address => uint256)) allowances;
    }

    /////////////////
    // STORAGE
    /////////////////

    /**
     * @dev Returns token state fields from contract storage.
     */
    function transferStorage(
        bytes32 position
    )
        internal 
        pure 
        returns (IHyperserver.Transfer storage transfer) 
    {
        assembly {
            transfer.slot := position
        }
    }

    /**
     * @dev Returns token state fields from contract storage.
     */
    function tokenStorage(
        bytes32 position
    )
        internal
        pure
        returns (TokenStorage storage ts)
    {
        assembly {
            ts.slot := position
        }
    }

    //////////////////////////////////////////////
    // FUNCTIONS
    //////////////////////////////////////////////

    function isAuthorised(
        bytes32 tokenPosition,
        address signer,
        uint256 nonce
    ) public {
        // Get the token
        TokenStorage storage thisToken = Token.tokenStorage(tokenPosition);

        // Require adequate balance
        require(thisToken.balances[signer] > thisToken.details.required, "Inadequeate balance");

        // Require new nonce
        require(thisToken.nonces[signer] < nonce, "Invalid nonce");
    }

    function issue(
        IHyperserver.Transfer memory transfer
    ) public {
        // Get the relevant slot
        bytes32 entryPosition = transfer.details.route[transfer.path][transfer.step];

        // Get the hash of the current entry in the route and retreieve the entry
        Ledger.Entry memory entry = Ledger.entry(entryPosition); // Get the data from the current step in the route

        // Get the token
        TokenStorage storage thisToken = Token.tokenStorage(entryPosition);

        // Require is a callable server address
        require(entry.typeHash == bytes8(keccak256("SERVER")));

        // Move to the next step in the route.
        transfer.step++;

        // Get the server to call
        address server = addr(entry.dataHash);
        
        // Get the recipient
        address recipient = decodeAddress(IHyperserver(server).POST(transfer));
        
        // Return the data, decode and add the balance
        thisToken.balances[recipient] += transfer.details.amount;
        
        // Add the transfer to storage
        _appendTransfer(transfer);
    }
    
    function _appendTransfer(
        IHyperserver.Transfer memory transfer
    ) internal {
        // The data hash of the sig/location it will be stored, not to be confused with the dataHash it is signing
        bytes32 dataHashOfTransfer = keccak256(abi.encode(transfer));
        
        // Push the storage pointer of the transfer to the ledger 
        Ledger.append(bytes8(keccak256("TRANSFER")), dataHashOfTransfer);
    }

    function decodeAddress(bytes memory data) public pure returns (address) {
        // Require correct size
        require(data.length >= 20, "Data is too short to be a valid address");

        // Decoding the data to an address type
        address decodedAddress = abi.decode(data, (address));

        return decodedAddress;
    }

    // Convert a bytes32 type to an address.
    function addr(bytes32 dataHash) internal pure returns (address) {
        return address(uint160(uint256(dataHash))); // Safely convert the hash to an address.
    }

}