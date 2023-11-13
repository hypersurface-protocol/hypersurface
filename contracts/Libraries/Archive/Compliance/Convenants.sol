// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

library Covenants {

    // Events
    event CovenantRequirementUpdated(address registry, bytes32 id, uint256 required, bool included);
    event BlacklistedStatusUpdated(address account, bool blacklisted);

    // Struct for holding covenant information
    struct CovenantRequired {
        address registry;
        bytes32 id;
        uint256 required;
        bool included; // Indicates if the covenant requirement is for including accounts      
    }

    // Struct for holding all covenants-related data
    struct CovenantsStorage {
        CovenantRequired[] covenantsRequired;
        mapping(address => bool) blacklisted; // Mapping from user address to blacklisting status.
    }
    
    bytes32 constant COVENANTS_POSITION = keccak256("covenants.storage");

    function getCovenantsStorage() internal pure returns (CovenantsStorage storage cs) {
        bytes32 position = COVENANTS_POSITION;
        assembly {
            cs.slot := position
        }
    }

    // Functions to manage covenants data
    function postAddCovenantRequirement(
        address registry,
        bytes32 id,
        uint256 required,
        bool included // Indicates if this covenant requirement is for including accounts
    ) external {
        CovenantsStorage storage covenants = getCovenantsStorage();

        for (uint256 i = 0; i < covenants.covenantsRequired.length; i++) {
            require(
                covenants.covenantsRequired[i].registry != registry || covenants.covenantsRequired[i].id != id,
                "Covenant requirement already exists."
            );
        }

        covenants.covenantsRequired.push(CovenantRequired({
            registry: registry,
            id: id,
            required: required,
            included: included // Set the inclusion status
        }));

        emit CovenantRequirementUpdated(registry, id, required, included);
    }

    function postRemoveCovenantRequirement(address registry, bytes32 id) external {
        CovenantsStorage storage covenants = getCovenantsStorage();

        uint256 length = covenants.covenantsRequired.length;
        bool found = false;
        for (uint256 i = 0; i < length; i++) {
            if (covenants.covenantsRequired[i].registry == registry && covenants.covenantsRequired[i].id == id) {
                covenants.covenantsRequired[i] = covenants.covenantsRequired[length - 1];
                covenants.covenantsRequired.pop();
                found = true;
                break;
            }
        }
        require(found, "Covenant requirement does not exist.");
        emit CovenantRequirementUpdated(registry, id, 0, false);
    }

    function postBlacklisted(address account, bool _blacklisted) external {
        CovenantsStorage storage covenants = getCovenantsStorage();
        
        covenants.blacklisted[account] = _blacklisted;
        emit BlacklistedStatusUpdated(account, _blacklisted);
    }

    function isBlacklisted(address account) external view returns (bool) {
        CovenantsStorage storage covenants = getCovenantsStorage();
        return covenants.blacklisted[account];
    }

    function getCovenantRequirements() external view returns (CovenantRequired[] memory) {
        CovenantsStorage storage covenants = getCovenantsStorage();
        return covenants.covenantsRequired;
    }

    // Compliance checks
    function checkTransferEligibility(address from, address to) external view returns (bool) {
        CovenantsStorage storage covenants = getCovenantsStorage();

        // Check if either address is blacklisted
        if (covenants.blacklisted[from] || covenants.blacklisted[to]) {
            return false;
        }

        // Check each covenant requirement
        for (uint256 i = 0; i < covenants.covenantsRequired.length; i++) {
            CovenantRequired storage requirement = covenants.covenantsRequired[i];
            // If the covenant is for inclusion and the attribute matches, return true
            if (requirement.included && checkCovenant(to, requirement)) {
                return true;
            }
        }

        // If no specific covenants are found, return true as default
        return true;
    }

    // Helper function to check individual covenants
    // This function would need to be implemented based on the actual covenant logic
    function checkCovenant(address to, CovenantRequired storage requirement) internal view returns (bool) {
        // Pseudocode:
        // This would typically check against a covenant registry contract
        // return CovenantRegistry(requirement.registry).verifyCovenant(to, requirement.id, requirement.included);
        return true;
    }
}