// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    LWallet Library: This assumes priviledged access for simplicity,
    meaning the user can execute actions without additional checks.
*/

import "../IHyperserver.sol";
import "./Ledger.sol";
import "./Token.sol";
import "./Archive/Security/VerifySignature.sol";

library Key {
    
    ////////////////
    // EVENTS
    ////////////////

    // Event to log the receipt of tokens
    event TokenReceived(address indexed server, address indexed signer, bytes32 tokenHash, uint256 amount);
    
    ////////////////
    // VARS
    ////////////////

    struct LoggedToken {
        uint256 amount;
        address server;
        mapping(address => uint256) allowances; // Operator address
    }

    struct Log {
        bytes32[] loggedTokenHashes; // Records the tokens associated with a key
        mapping(bytes32 => LoggedToken) loggedTokens; // Records the key data of tokens received by a key
    }

    struct Key {
        address addr;
        uint256 thisNonce; // This transaction nonce
    }

    //////////////////////////////////////////////
    // READ DYNAMIC STORAGE
    //////////////////////////////////////////////

    // Get's a logs from storage
    function logStorage(
        bytes32 keyPosition
    )
        internal 
        pure 
        returns (Log storage log) 
    {
        assembly {
            log.slot := keyPosition
        }
    }

    // Get's a single key from storage slot
    function keyStorage(
        bytes32 keyPosition
    )
        internal 
        pure 
        returns (Key storage key) 
    {
        assembly {
            key.slot := keyPosition
        }
    }

    //////////////////////////////////////////////
    // FUNCTIONS
    //////////////////////////////////////////////

    function register(
        IHyperserver.Transfer memory transfer
    ) public returns (bytes memory data) {
        
        // Receiver hash, assumes receiver at previous step e.g., "wallet", "treasury", "fund-i", "spv-1", "london", "sales"
        bytes32 receiverHash = transfer.route[transfer.step - 1];

        // Retrieve the key information from storage
        Key storage thisKey = keyStorage(receiverHash);

        // Require the entry is a key
        require(thisKey.addr != address(0));

        // Get the signer key
        address signer = Verify.verifyTransfer(transfer);

        // Extract the transfer details
        address server = transfer.server;
        bytes32 tokenHash = transfer.tokenHash;
        uint256 amount = transfer.details.amount;

        // Log receipt
        emit TokenReceived(server, signer, tokenHash, amount);

        // Return the address to send the token to
        return abi.encode(thisKey.addr);
    }

    function execute(
        IHyperserver.Transfer memory transfer
    ) public returns (bytes memory) {
        
        // Verify the signature of the first transfer
        address signer = Verify.VerifySignature(transfer.details);
        
        // Receiver hash, assumes receiver at previous step e.g., "wallet", "treasury", "fund-i", "spv-1", "london", "sales"
        bytes32 keyHash = transfer.route[transfer.path][transfer.step - 1];

        // Retrieve the key information from storage
        Key storage thisKey = keyStorage(keyHash);

        // Check the authorisation
        Token.authorised(keyHash, signer, transfer.details.nonce);

        // Forward transfer
        IHyperserver.Transfer[] memory forwardTransfer = _signForwardRoute(signer, transfer);

        // Set the nonce
        transfer.details.nonce = thisKey.nonce;        
        
        // Increment the path to the next step
        transfer.path++; 

        // Reset the step
        transfer.step = 0;
        
        // Sign the transfer
        transfer = Sign.signTransfer(keyHash, transfer);
        
        // TODO execute the transfer
        // Should add the transfer or issuance to storage
    }

}