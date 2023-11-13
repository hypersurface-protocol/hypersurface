// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IHyperserver.sol";

library Document {

    /**
     * @dev Storage pointer.
     */
    bytes32 constant DOCUMENT_STORAGE_POSITION = keccak256("document");
    
    ////////////////
    // STATE
    ////////////////

    /**
     * @dev Bundles all document storage into a struct.
     */
    struct DocumentStorage {
        string document;
    }

    //////////////////////////////////////////////
    // READ STORAGE
    //////////////////////////////////////////////

    /**
     * @dev Returns document state fields from contract storage.
     */
    function documentStorage(
        bytes32 position
    )
        internal
        pure
        returns (DocumentStorage storage ds)
    {
        assembly {
            ds.slot := position
        }
    }

    function getDocument(
        bytes32 position
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encode(documentStorage(keccak256(abi.encode(position, DOCUMENT_STORAGE_POSITION))));
    }

}