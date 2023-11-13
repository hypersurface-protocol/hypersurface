// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library LOwnable {
    
    ////////////////
    // CONSTRUCTOR
    ////////////////

    /**
     * @dev Storage pointer. 
     */
    bytes32 constant OWNABLE_STORAGE_POSITION = keccak256("hyperframe.standard.ownable.storage");

    ////////////////
    // STATE
    ////////////////

    /**
     * @dev Bundles all ownable storage into a struct. 
     */
    struct OwnableStorage {

        // Owner of the contract
        address contractOwner;
    }

    //////////////////////////////////////////////
    // READ STORAGE
    //////////////////////////////////////////////

    /**
     * @dev Returns ownable state fields from contract storage. 
     */
    function _ownableStorage()
        internal
        pure
        returns (OwnableStorage storage os)
    {
        bytes32 position = OWNABLE_STORAGE_POSITION;
        assembly {
            os.slot := position
        }
    }

    ////////////////
    // ERRORS
    ////////////////

    /**
     * @notice No contract owner.
     */    
    error NotContractOwner(address _user, address _contractOwner);

    ////////////////
    // EVENTS
    ////////////////

    /**
     * @notice Ownership of the contract was transferred to a new account.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    //////////////////////////////////////////////
    // ENFORCERS
    //////////////////////////////////////////////

    /**
     * @notice Ensure the caller is the contract owner.
     */
    function _enforceIsContractOwner()
        internal
        view
    {
        // Ensure caller is owner
        if (msg.sender != ownerStorage().contractOwner)
            revert NotContractOwner(msg.sender, ownerStorage().contractOwner);
    }
    
    //////////////////////////////////////////////
    // SETTERS
    //////////////////////////////////////////////

    /**
     * @notice Transfer ownership of the contract.
     */
    function _setContractOwner(
        address _newOwner
    )
        internal
    {
        // Ensure caller is owner
        _enforceIsContractOwner();
        
        // Get previous owner 
        address previousOwner = ownerStorage().contractOwner;

        // Set new owner in owner storage
        ownerStorage().contractOwner = _newOwner;

        // Emit event
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    //////////////////////////////////////////////
    // GETTERS
    //////////////////////////////////////////////

    /**
     * @notice Return the contract owner.
     */
    function _getOwner()
        internal
        view
        returns (address contractOwner_)
    {
        // Get owner from storage
        contractOwner_ = ownerStorage().contractOwner;
    }

}