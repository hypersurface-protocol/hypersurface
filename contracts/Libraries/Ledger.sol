// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
    Ledger library: This library manages a ledger that records entries with type
    and data hashes, as well as their relationships. It has functions to append
    new entries and retrieve them by their hashes.
*/

library Ledger {

    event EntryAdded(uint256 indexed index, bytes8 indexed typeHash, bytes32 previousHash, bytes32 thisHash);

    struct Entry {
        bytes8 typeHash;
        bytes32 previousHash;
        bytes32 dataHash;
        bytes32 thisHash;
    }

    struct LedgerStorage {
        Entry[] ledger;
        mapping(bytes32 => uint256) entryIndex;
    }

    bytes32 constant LEDGER_POSITION = keccak256("ledger.storage");

    function getLedgerStorage() internal pure returns (LedgerStorage storage ls) {
        bytes32 position = LEDGER_POSITION;
        assembly {
            ls.slot := position
        }
    }

    function append(bytes8 typeHash, bytes32 dataHash) internal returns(bytes32 thisHash) {
        
        // Gets the LedgerStorage struct from storage 
        LedgerStorage storage ls = getLedgerStorage();
        
        bytes32 previousHash = ls.ledger.length > 0 
            ? ls.ledger[ls.ledger.length - 1].thisHash
            : bytes32(0);

        thisHash = keccak256(abi.encode(typeHash, dataHash, previousHash));

        Entry memory newEntry = Entry({
            typeHash: typeHash,
            previousHash: previousHash,
            dataHash: dataHash,
            thisHash: thisHash
        });

        ls.ledger.push(newEntry);
        uint256 index = ls.ledger.length - 1;
        ls.entryIndex[thisHash] = index;


        emit EntryAdded(index, typeHash, previousHash, thisHash);
    }

    function entry(bytes32 entryHash) internal view returns (Entry storage) {
        
        // Gets the LedgerStorage struct from storage 
        LedgerStorage storage ls = getLedgerStorage();
        
        require(ls.entryIndex[entryHash] != 0 || (ls.ledger.length > 0 && entryHash == ls.ledger[0].thisHash), "Entry does not exist.");

        return ls.ledger[ls.entryIndex[entryHash]];
    }
}