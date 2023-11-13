// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IHyperserver.sol";

library Signer {

    struct KeyPair {
        bytes32 publicKey;
        bytes32 privateKey;
    }

    function _sign(bytes32 hash) internal returns (bytes memory signedHash) {
        bytes memory signedHash;
    }

    function signTransfer(bytes32 keyHash, IHyperserver.Transfer memory transfer) public returns (IHyperserver.Transfer memory) {

        // TODO, use the key hash to get the signing key from private storage

        bytes32 transferHash = keccak256(abi.encode(transfer.details));
        transfer.sig = _sign(transferHash);

        return transfer;
    }

}