// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

library Compliance {

    // Events
    event ClaimRequirementUpdated(address registry, bytes32 id, uint256 required);
    event WhitelistedStatusUpdated(address account, bool whitelisted);

    // Struct for holding claim information
    struct Claim {
        address registry;
        bytes32 id;
        uint256 required;        
    }

    // Struct for holding all compliance-related data
    struct ComplianceStorage {
        Claim[] claimsRequired;
        mapping(address => bool) whitelisted; // Mapping from user address to bool exemption status.
    }
    
    bytes32 constant COMPLIANCE_POSITION = keccak256("compliance.storage");

    function getComplianceStorage() internal pure returns (ComplianceStorage storage cs) {
        bytes32 position = COMPLIANCE_POSITION;
        assembly {
            cs.slot := position
        }
    }

    // Functions to manage compliance data
    function addClaimRequirement(address registry, bytes32 id, uint256 required) public {

        // Get compliance from storage
        ComplianceStorage storage compliance = getComplianceStorage();
        
        // Ensure the claim does not already exist
        for (uint256 i = 0; i < compliance.claimsRequired.length; i++) {
            require(
                compliance.claimsRequired[i].registry != registry || compliance.claimsRequired[i].id != id,
                "Claim requirement already exists."
            );
        }
        compliance.claimsRequired.push(Claim({
            registry: registry,
            id: id,
            required: required
        }));
        emit ClaimRequirementUpdated(registry, id, required);
    }

    function removeClaimRequirement(address registry, bytes32 id) public {
        
        ComplianceStorage storage compliance = getComplianceStorage();

        uint256 length = compliance.claimsRequired.length;
        bool found = false;
        for (uint256 i = 0; i < length; i++) {
            if (compliance.claimsRequired[i].registry == registry && compliance.claimsRequired[i].id == id) {
                compliance.claimsRequired[i] = compliance.claimsRequired[length - 1];
                compliance.claimsRequired.pop();
                found = true;
                break;
            }
        }
        require(found, "Claim requirement does not exist.");
        emit ClaimRequirementUpdated(registry, id, 0);
    }

    function setWhitelisted(address account, bool whitelisted) external {
        
        ComplianceStorage storage compliance = getComplianceStorage();
        
        compliance.whitelisted[account] = whitelisted;
        emit WhitelistedStatusUpdated(account, whitelisted);
    }

    // Gettecs
    function getClaimRequirements() external view returns (Claim[] memory) {
        ComplianceStorage storage compliance = getComplianceStorage();

        return compliance.claimsRequired;
    }

    function isWhitelisted(address account) external view returns (bool) {
        ComplianceStorage storage compliance = getComplianceStorage();

        return compliance.whitelisted[account];
    }

    // Compliance checks
    function checkTransferEligibility(address from, address to) public view returns (bool) {
        ComplianceStorage storage compliance = getComplianceStorage();

        // If the sender or recipient is whitelisted, the transfer is always eligible
        if (compliance.whitelisted[from] || compliance.whitelisted[to]) {
            return true;
        }
        
        // Here you would put the logic to check each Claim against the actual claims.
        // This could involve interacting with a claims registry contract.
        // For example:
        // for (uint256 i = 0; i < compliance.claimsRequired.length; i++) {
        //     Claim storage requirement = compliance.claimsRequired[i];
        //     if (!checkClaim(to, requirement)) {
        //         return false;
        //     }
        // }

        // The actual implementation would depend on the interface of the claims registry.
        // For now, return true as a placeholder.
        return true;
    }

    // Helper function to check individual claims
    // This function is a placeholder and would need to be implemented based on the actual claims registry logic
    function checkClaim(address to, Claim storage requirement) internal view returns (bool) {
        // Pseudocode:
        // return ClaimsRegistry(requirement.registry).verifyClaim(to, requirement.id);
        return true;
    }
}
