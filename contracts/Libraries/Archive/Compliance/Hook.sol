// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IHyperserver.sol";
import "./Token.sol";
import "./Verify.sol";

library Hook {

    error InvalidEntryType();

    struct ClaimRequired {
        address registry;
        bytes32 id;
        uint256 required;        
    }

    struct ComplianceStorage {
        ClaimRequired[] claimsRequired;
        bytes32 returnDataHash;
        bytes32 returnAmount;
    }

    // Get's a single signature from storage slot
    function getHook(
        bytes32 position
    )
        internal 
        pure 
        returns (Hook storage signature) 
    {
        assembly {
            signature.slot := position
        }
    }
    
    /**
        This function handles the signed submission of a document. 
        The user adds an entry with a document
        The user adds a signature of the document
        The user transfers the signature entry to the submit route. 
        The submit route route is something like [server:0x01a, library:Lhook, function:submit, dataHash: keccack256(investor-nda)]
        Because the route includes the dataHash of the signed document, it doesn't need to lookup the entry
     */
    function submit(
        IHyperserver.Transfer memory transfer
    ) public view returns (IHyperserver.Transfer[] memory forwardTransfers) {
        
        // Ensure there are transfers to process
        require(transfers.length > 0, "No transfers provided.");

        // Check that there is still one step to resolve, should be no more, no less
        require(transfers.step == transfers[0].route.length - 1, "There should be exactly one step remaining");

        // TODO Not sure if can convert directly to bytes32
        bytes32 agreementDataHash = bytes32(transfers[0].route[transfers.step]);  

        // Load the hook from storage
        Hook storage hook = getHook(agreementDataHash);
        
        // Verify the signature of the current transfer
        address signer = LVerify.verifySplit(
            keccak256(abi.encode(transfers[i].nonce, transfers[i].route)),
            transfers[i].r,
            transfers[i].s,
            transfers[i].v
        );

        // Check the signer has been issued the token
        require(authorised(agreementDataHash, signer));

        // Check the nonce is valid in case of replay
        require(thisKey.signerNonce[signer] < transfers[i].nonce, "Invalid nonce.");
        
        // Iterate through any required claims and check elligibility
        require(checkClaims(hook.claimsRequired, signer));

        // Issues the returnData hash to the signer
        bytes memory newTransferData = token.issue(hook.returnDataHash, signer, hook.returnAmount);

        // Prepare an array to hold the forward route transfers, excluding the first transfer
        forwardTransfers = new IHyperserver.Transfer[](transfers.length - 1);

        // Require that the next transfer is the return route
        require(transfers.length == 1);

        // IMPORTANT, assumes the last part in the route will be empty
        transfers[i].route[route.length - 1] = newTransferData;

        // Rebuild the current transfer with a zero signature, as the signatures will be handled later
        forwardTransfers[i - 1] = IHyperserver.Transfer({
            r: bytes32(0),
            s: bytes32(0),
            v: uint8(0),
            route: transfers[i].route,
            nonce: thisKey.thisNonce,
            step: 0
        });

        // Get the hash of the current entry in the route.
        bytes32 entryHash = b32(
            forwardTransfers[0].route[forwardTransfers[0].step] // Get the data from the current step in the route
        );

        // Retrieve the entry from the ledger using the hash.
        Ledger.Entry storage thisEntry = Ledger.entry(entryHash);

        // If the entry is a pointer (tag), update to point to the actual data.
        if (isTag(thisEntry.typeHash))
            thisEntry = Ledger.entry(thisEntry.dataHash);

        // Depending on the type of entry, delegate the call, resolve further, or handle a function call.
        if (isServer(thisEntry.typeHash)) {
            forwardTransfers[0].step++; // Move to the next step in the route.
            return IHyperserver(
                addr(thisEntry.dataHash) // Convert hash to an address and delegate the call.
            ).POST(forwardTransfers);
        } else { // If none of the above types match, revert.
            revert InvalidEntryType();
        }
        // TODO
        // The forwardTransfers handles how the logging of the return
        // So may be something like [johnsmith, wallet-1, log]
        // Either POST directly or pass back to the calling contract
    }

    
    /**
     * @dev Returns boolean as to the elligibility of a receiver by iterating through the required
     * claims and ensuring that the receiver has them in claim registry.
     *
     * @param account The address of the account to check elligibility on.
     */
    function checkClaims(
        ClaimRequired[] claimsRequired,
        address account
    )
        public
        view
        returns (bool)
    {
        // TODO, maybe this needs to be changes so that it is [server, Ltoken, balanceOf, tokenHash, address]
        
        // Iterate through required claims
        for (uint256 i = 0; i < claimsRequired.length; i++)
            // Lookup the balance at the hyperserver and compare against tokens required
            if (IHyperserver(claimsRequired[i].registry).balance(claimsRequired[i].id, account) < claimsRequired[i].required)
                return false;
        return true;
    }
    
}