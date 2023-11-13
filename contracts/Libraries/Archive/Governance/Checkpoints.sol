// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

library Checkpoints {
 
    ////////////////
    // CONSTRUCTOR
    ////////////////

    /**
     * @dev Storage pointer. 
     */
    bytes32 constant CHECKPOINTS_STORAGE_POSITION = keccak256("hyperframe.standard.checkpoints.storage");

    ////////////////
    // STATE
    ////////////////

    /**
     * @dev 
     */
    struct Checkpoint {

        // Timestamp of transfer checkpoint
        uint256 timestamp;

        // Number of votes at checkpoint
        uint256 votes;
    }

    /**
     * @dev Bundles all checkpoints storage into a struct. 
     */
    struct CheckpointsStorage {

        // Mapping from account to tokenId to number of checkpoints
        mapping(address => mapping(uint256 => uint256)) _checkpointCount;

        // Mapping from account to tokenId to ?? to checkpoint
        mapping(address => mapping(uint256 => mapping(uint256 => Checkpoint))) _checkpoints;
    }


    //////////////////////////////////////////////
    // READ STORAGE
    //////////////////////////////////////////////

    /**
     * @dev Returns checkpoints state fields from contract storage. 
     */
    function _checkpointsStorage()
        internal
        pure
        returns (CheckpointsStorage storage checkpointsStorage)
    {
        bytes32 position = CHECKPOINTS_STORAGE_POSITION;
        assembly {
            checkpointsStorage.slot := position
        }
    }
    
    //////////////////////////////////////////////
    // GETTERS
    //////////////////////////////////////////////

    /**
     * @notice Return the current number of votes held.
     */
    function _getCurrentVotesByTokenId(
        address account,
        uint256 tokenId
    )
        internal
        view
        returns (uint256)
    {
        // Get checkpoint count
        uint256 _checkPointsStorage()._checkpointCount = _checkPointsStorage()._checkpointCount[account][tokenId];

        // If has checkpounts, return votes at last checkpoint
        if (0 < _checkPointsStorage()._checkpointCount)
            return _checkPointsStorage()._checkpoints[account][tokenId][_checkPointsStorage()._checkpointCount - 1].votes;

        // Else, return zero
        else 
            return 0;
    }

    /**
     * @notice Return the current delegate of an account by token id.
     */
    function _getPriorVotes(
        address account,
        uint256 tokenId,
        uint256 timestamp
    )
        internal
        view
        returns (uint256)
    {
        // Cannot request votes for timestamp that has not happened yet
        if (block.timestamp <= timestamp)
            revert Undetermined();

        // Get number of checkpoints for account 
        uint256 _checkPointsStorage()._checkpointCount = _checkPointsStorage()._checkpointCount[account][tokenId];

        // If account has no activity return zero votes
        if (_checkPointsStorage()._checkpointCount == 0)
            // #TODO return zero or query current shareholding
            return 0;

        // Get the previous checkpoint
        uint256 prevCheckpoint = _checkPointsStorage()._checkpointCount - 1;
        
        // If prev checkpoint timestamp is less than current timesTimestamp of transfer checkpointmp, return votes
        if (_checkPointsStorage()._checkpoints[account][tokenId][prevCheckpoint].timestamp <= timestamp)
            return _checkPointsStorage()._checkpoints[account][tokenId][prevCheckpoint].votes;

        // If Timestamp of transfer checkpoint
        if (_checkPointsStorage()._checkpoints[account][tokenId][0].timestamp > timestamp)
            return 0;

        // Get time bounds to search between
        uint256 lower;
        uint256 upper = prevCheckpoint;

        // While lower bound is less than upper bound
        while (lower < upper) {

            // 
            uint256 center = upper - (upper - lower) / 2;

            /Timestamp of transfer checkpoint
            if (_checkPointsStorage()._checkpoints[account][tokenId][center].timestamp == timestamp)
                return _checkPointsStorage()._checkpoints[account][tokenId][center].votes;

            /Timestamp of transfer checkpoint
            else if (_checkPointsStorage()._checkpoints[account][tokenId][center].timestamp < timestamp)
                lower = center;

            // 
            else
                upper = center - 1;
        }

        // Return the number of votes 
        return
            _checkPointsStorage()._checkpoints[account][tokenId][lower].votes;
    }

    //////////////////////////////////////////////
    // INTERNAL FUNCTIONS
    //////////////////////////////////////////////

    function _writeCheckpoint(
        address recipient,
        uint256 tokenId,
        uint256 checkpointCount,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        // Timestamp of transfer checkpoint
        if (_checkPointsStorage()._checkpointCount != 0 && _checkPointsStorage()._checkpoints[recipient][tokenId][_checkPointsStorage()._checkpointCount - 1].timestamp == block.timestamp)
            _checkPointsStorage()._checkpoints[recipient][tokenId][_checkPointsStorage()._checkpointCount - 1].votes = _safeCastTo216(newVotes);

        else {
            _checkPointsStorage()._checkpoints[recipient][tokenId][_checkPointsStorage()._checkpointCount] = Checkpoint(block.timestamp, newVotes);

            _checkPointsStorage()._checkpointCount[recipient][tokenId]++;
        }

        emit DelegateVotesChanged(recipient, tokenId, oldVotes, newVotes);
    }

}