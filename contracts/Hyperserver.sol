// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IHyperserver.sol";
import "./Libraries/Ledger.sol";

contract Hyperserver {
    
    // Define custom errors for reverts to save gas and provide clearer errors.
    error InvalidStep();
    error NotLibrary();
    error CallFailed();
    error InvalidEntryType();

    // This function resolves a route of transfer by looking up entries in the Ledger
    // and potentially delegating calls to other contracts based on those entries.
    function POST(
        IHyperserver.Transfer memory transfer
    ) public returns (bytes memory) {

        // Validate that the current step is within the bounds of the route array.
        if (transfer.step >= transfer.details.route.length)
            revert InvalidStep();
        
        // Get the hash of the current entry in the route and retreieve the entry
        Ledger.Entry memory entry = Ledger.entry(transfer.details.route[transfer.path][transfer.step]); // Get the data from the current step in the route

        // If the entry is a pointer (tag), update to point to the actual data.
        if (isTag(entry.typeHash))
            entry = handlePointer(entry, transfer);

        // Depending on the type of entry, delegate the call, resolve further, or handle a function call.
        if (isServer(entry.typeHash))
            handleServer(entry, transfer);
        
        // If it's a library, resolve the library which involves further steps.
        else if (isLibrary(entry.typeHash))
            return handleLibrary(entry, transfer);
            
        // If none of the above types match, revert.
        else 
            revert InvalidEntryType();
    }

    // TODO, the following handle functions should just be usable by both GET and POST methods, refactor accordingly

    function handlePointer(
        Ledger.Entry memory entry,
        IHyperserver.Transfer memory transfer
    ) public returns(Ledger.Entry memory) {

        // Get the underlying entry the pointer points to 
        return Ledger.entry(entry.dataHash); 
    }

    function handleServer(
        Ledger.Entry memory entry,
        IHyperserver.Transfer memory transfer
    ) public returns(bytes memory) {
    
        // Move to the next step in the route.
        transfer.step++;

        // Get the server to call
        address server = addr(entry.dataHash);
        
        // Return the data
        return IHyperserver(server).POST(transfer);
    }

    function handleLibrary(
        Ledger.Entry memory entry,
        IHyperserver.Transfer memory transfer
    ) internal returns (bytes memory) {
        
        // Ensure we have not reached the end of the route.
        if (transfer.step >= transfer.details.route[transfer.path].length - 1)
            revert InvalidStep();
        
        // Assume current step is the function selector and get the libraryAddress pointer
        bytes32 libraryHash = transfer.details.route[transfer.path][transfer.step];

        // Get the address of the library from the libraries slot
        address libraryAddress = addr(Ledger.entry(libraryHash).dataHash);
        
        // Retrieve the entry from the ledger using the hash.
        Ledger.Entry storage selectorEntry = Ledger.entry(transfer.details.route[transfer.path][transfer.step]);
        
        // Require is a function selector
        require(isSelector(selectorEntry.typeHash));

        // Get the function selector from the current step's data.
        bytes4 selector = bytes4(selectorEntry.dataHash);

        // Increment the step
        transfer.step++;

        // Perform a delegate call to the library function.
        (bool success, bytes memory data) = libraryAddress.delegatecall(abi.encodeWithSelector(selector));

        require(success, "Require the call has been succesful");

        return data;
    }

    // Convert a byte array to a bytes32 type.
    function b32(bytes memory data) internal pure returns (bytes32 result) {
        require(data.length == 32, "Source must be 32 bytes.");
        // Perform the conversion in assembly for efficiency.
        assembly {
            result := mload(add(data, 32))
        }
    }

    // Convert a bytes32 type to an address.
    function addr(bytes32 dataHash) internal pure returns (address) {
        return address(uint160(uint256(dataHash))); // Safely convert the hash to an address.
    }

    // Check if the type hash is get.
    function isGet(bytes8 typeHash) public returns (bool) {
        return typeHash == bytes8(keccak256("GET"));
    }

    // Check if the type hash is post.
    function isPost(bytes8 typeHash) public returns (bool) {
        return typeHash == bytes8(keccak256("POST"));
    }

    // Check if a type hash corresponds to a contract.
    function isServer(bytes8 typeHash) internal pure returns (bool) {
        return typeHash == bytes8(keccak256("SERVER"));
    }

    // Check if a type hash corresponds to a library.
    function isLibrary(bytes8 typeHash) internal pure returns (bool) {
        return typeHash == bytes8(keccak256("LIBRARY"));
    }

    // Check if a type hash corresponds to a function.
    function isSelector(bytes8 typeHash) internal pure returns (bool) {
        return typeHash == bytes8(keccak256("FUNCTION"));
    }

    // Check if a type hash corresponds to a tag.
    function isTag(bytes8 typeHash) internal pure returns (bool) {
        return typeHash == bytes8(keccak256("TAG"));
    }
}