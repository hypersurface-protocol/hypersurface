// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IHyperserver.sol";
import "./Ledger.sol";

library Signer {

    // Define a struct for signature components along with the data hash
    struct Signature {
        bytes32 dataHash;
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    // Get's a single signature from storage slot
    function getSignature(
        bytes32 position
    )
        internal 
        pure
        returns (Signature storage signature) 
    {
        assembly {
            signature.slot := position
        }
    }

    function signDataHash(
        bytes32 dataHash
    ) public returns (bytes32 signatureEntryHash) {
        
        // Sign the dataHash
        Signature memory signedData = sign(dataHash);

        // Get the raw signature
        bytes memory encodedSignature = abi.encode(signedData);
        
        // Get the data hash of the location it will be stored, not to be confused with the dataHash it is signing
        bytes32 dataHashOfSignature = keccak256(encodedSignature);
        
        // Gets the Signature struct in storage 
        Signature storage signature = getSignature(dataHashOfSignature);

        // Updates the empty Signature in storage slot with Signature just generated 
        signature.dataHash = signedData.dataHash;
        signature.r = signedData.r;
        signature.s = signedData.s;
        signature.v = signedData.v;

        // Push the storage pointer to the ledger 
        return Ledger.append(sigTypeHash(), dataHashOfSignature);
    }

    function sigTypeHash() public pure returns (bytes8) {
        return bytes8(keccak256("SIGNATURE"));
    }

    // A sign function that would generate a signature for the data hash
    function sign(bytes32 dataHash) private pure returns (Signature memory) {
        // #TODO This is just a placeholder.
        // In a real scenario, the signature components would be created using Oasis Sapphire Precompile
        return Signature({
            dataHash: dataHash,
            r: bytes32(0),
            s: bytes32(0),
            v: 0
        });
    }
}
