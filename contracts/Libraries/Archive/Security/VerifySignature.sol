// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library VerifySignature {

    // Define a struct for signature components along with the data hash
    struct Signature {
        bytes32 dataHash;
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    function verify(
        Signature calldata sig
    ) public pure returns (address) {
        // Return the address of the signer
        return ecrecover(sig.dataHash, sig.v, sig.r, sig.s);
    }

    function verifySplit(
        bytes32 dataHash,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public pure returns (address) {
        // Return the address of the signer
        return ecrecover(dataHash, v, r, s);
    }
    
    function verifyRaw(
        bytes32 expectedDataHash,
        bytes memory rawSignature 
    ) public pure returns (address) {

        // Expects the entry to be structured in raw form
        Signature memory sig = abi.decode(rawSignature, (Signature));

        // Require that the data hash is the expected type
        require(sig.dataHash == expectedDataHash);

        // Return the address of the signer
        return ecrecover(sig.dataHash, sig.v, sig.r, sig.s);
    }

    
}