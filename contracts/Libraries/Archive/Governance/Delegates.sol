// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

contract LDelegates {
 
    ////////////////
    // CONSTRUCTOR
    ////////////////

    /**
     * @dev Storage pointer. 
     */
    bytes32 constant DELEGATES_STORAGE_POSITION = keccak256("hyperframe.standard.delegates.storage");

    ////////////////
    // STATE
    ////////////////

    /**
     * @dev 
     */
    struct Checkpoint {

        // Timestamp of transfer checkpoint
        uint256 timestamp;

        // Number of shares at checkpoint
        uint256 shares;
    }

    /**
     * @dev Bundles all delegates storage into a struct. 
     */
    struct DelegatesStorage {
        
        // Mapping from account to tokenId to delegate
        mapping(address => mapping(uint256 => address)) _delegates;

        // Mapping from account to tokenId to number of checkpoints
        mapping(address => mapping(uint256 => uint256)) _checkpointCount;

        // Mapping from account to tokenId to ?? to checkpoint
        mapping(address => mapping(uint256 => mapping(uint256 => Checkpoint))) _checkpoints;
    }


    //////////////////////////////////////////////
    // READ STORAGE
    //////////////////////////////////////////////

    /**
     * @dev Returns delegates state fields from contract storage. 
     */
    function _delegatesStorage()
        internal
        pure
        returns (DelegatesStorage storage delegatesStorage)
    {
        bytes32 position = DELEGATES_STORAGE_POSITION;
        assembly {
            delegatesStorage.slot := position
        }
    }

    //////////////////////////////////////////////
    // SETTERS
    //////////////////////////////////////////////

    /**
     * @notice Delegate voting power to another person.
     */
    function setDelegate(
        address newDelegate,
        uint256 tokenId
    )
        internal
        payable
    {
        // Get the current delegate
        address currentDelegate = getDelegates(msg.sender, tokenId);

        // Get the person to delegate to
        _delegatesStorage()._delegates[msg.sender][tokenId] = newDelegate;

        // Transfer voting power
        _moveDelegates(
            currentDelegate,
            newDelegate,
            tokenId,
            balanceOf[msg.sender][tokenId]
        );

        // Emit event
        emit DelegateChanged(msg.sender, currentDelegate, newDelegate, tokenId);
    }
    
    //////////////////////////////////////////////
    // GETTERS
    //////////////////////////////////////////////

    /**
     * @notice Return the current delegate of an account by token id.
     */
    function _getDelegateByTokenId(
        address account,
        uint256 tokenId
    )
        internal
        view
        returns (address)
    {
        // Get current delegate
        address current = _delegatesStorage()._delegates[account][tokenId];

        // If not delegated return self account
        if (current == address(0))
            return account;

        // Else, return the delegate
        else 
            return current;
    }

    //////////////////////////////////////////////
    // INTERNAL FUNCTIONS
    //////////////////////////////////////////////

    function _moveDelegates(
        address currentAccount,
        address recipientAccount,
        uint256 tokenId,
        uint256 amount
    )
        internal
    {
        // If current account does not equal reciever
        if (currentAccount != recipientAccount && amount != 0) {

            // And current accout does not equal zero address
            if (currentAccount != address(0)) {
                uint256 srcRepNum = _delegatesStorage()._checkpointCount[currentAccount][tokenId];

                uint256 srcRepOld;

                srcRepOld = srcRepNum != 0
                    ? _delegatesStorage()._checkpoints[currentAccount][tokenId][srcRepNum - 1].shares
                    : 0;

                _writeCheckpoint(
                    currentAccount,
                    tokenId,
                    srcRepNum,
                    srcRepOld,
                    srcRepOld - amount
                );
            }

            if (recipientAccount != address(0)) {
                uint256 dstRepNum = _delegatesStorage()._checkpointCount[recipientAccount][tokenId];

                uint256 dstRepOld;

                dstRepOld = dstRepNum != 0
                    ? _delegatesStorage()._checkpoints[recipientAccount][tokenId][dstRepNum - 1].shares
                    : 0;
            
                _writeCheckpoint(
                    recipientAccount,
                    tokenId,
                    dstRepNum,
                    dstRepOld,
                    dstRepOld + amount
                );
            }
        }
    }


}