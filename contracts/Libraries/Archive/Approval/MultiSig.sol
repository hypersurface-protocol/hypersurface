// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

/**
    To be formatted.
 */

library MultiSig {

    struct MultiSigStorage {
        uint8 MAX_KEY_COUNT;
        uint256 required;
        address[] keys;
        mapping(address => uint256) keysByAddress;
        mapping(address => bool) keyExistsByAddress;
        mapping(uint256 => mapping(address => bool)) approvalsByTransactionHash;
    }

    event KeyAdded(address key);
    event KeyRemoved(address key);
    event Approved(address key, uint256 txHash);
    event Revoked(address key, uint256 txHash);
    event Submitted(uint256 txHash, address[] targets, uint256[] values, bytes[] calldatas);
    event Executed(uint256 txHash, address[] targets, uint256[] values, bytes[] calldatas);
    event RequirementChange(uint256 required);

    constructor(uint256 required) {
        require(required > 0, "MultiSig: requirement must be greater than 0");
        _storage.MAX_KEY_COUNT = 8;
        _storage.required = required;
    }

    function addKey(address key) public {
        require(msg.sender == address(this), "MultiSig: caller is not this contract");
        require(!_storage.keyExistsByAddress[key], "MultiSig: key already exists");
        require(key != address(0), "MultiSig: key is the zero address");
        uint8 newLength = uint8(_storage.keys.length + 1);
        require(newLength <= _storage.MAX_KEY_COUNT, "MultiSig: exceeds maximum key count");
        require(newLength > _storage.required, "MultiSig: not enough keys to meet requirement");

        _storage.keys.push(key);
        _storage.keyExistsByAddress[key] = true;

        emit KeyAdded(key);
    }

    function removeKey(address key) public {
        require(msg.sender == address(this), "MultiSig: caller is not this contract");
        require(_storage.keyExistsByAddress[key], "MultiSig: key does not exist");
        require(_storage.keys.length > 1, "MultiSig: cannot have zero keys");

        uint256 keyIndex = _storage.keysByAddress[key];
        _storage.keys[keyIndex] = _storage.keys[_storage.keys.length - 1];
        _storage.keys.pop();
        delete _storage.keyExistsByAddress[key];
        delete _storage.keysByAddress[key];

        emit KeyRemoved(key);
    }

    function replaceKey(address oldKey, address newKey) public {
        require(msg.sender == address(this), "MultiSig: caller is not this contract");
        require(_storage.keyExistsByAddress[oldKey], "MultiSig: old key does not exist");
        require(!_storage.keyExistsByAddress[newKey], "MultiSig: new key already exists");
        require(newKey != address(0), "MultiSig: new key is the zero address");

        removeKey(oldKey);
        addKey(newKey);
    }

    function approve(uint256 txHash) public {
        require(_storage.keyExistsByAddress[msg.sender], "MultiSig: key does not exist");
        require(!_storage.approvalsByTransactionHash[txHash][msg.sender], "MultiSig: key has already approved");

        _storage.approvalsByTransactionHash[txHash][msg.sender] = true;

        emit Approved(msg.sender, txHash);

        execute(txHash);
    }

    function revokeApproval(uint256 txHash) public {
        require(_storage.keyExistsByAddress[msg.sender], "MultiSig: key does not exist");
        require(_storage.approvalsByTransactionHash[txHash][msg.sender], "MultiSig: key has not approved");

        _storage.approvalsByTransactionHash[txHash][msg.sender] = false;

        emit Revoked(msg.sender, txHash);
    }

    function getApprovalCount(uint256 txHash) public view returns (uint8 approvalCount) {
        for (uint256 i = 0; i < _storage.keys.length; i++) {
            if (_storage.approvalsByTransactionHash[txHash][_storage.keys[i]]) {
                approvalCount++;
            }
        }
    }

    function getKeys() public view returns (address[] memory) {
        return _storage.keys;
    }

    function setRequirement(uint8 required) public {
        require(msg.sender == address(this), "MultiSig: caller is not this contract");
        require(required <= _storage.MAX_KEY_COUNT, "MultiSig: invalid requirement");
        require(required > 0, "MultiSig: requirement must be greater than 0");
        require(_storage.keys.length >= required, "MultiSig: not enough keys to meet requirement");

        _storage.required = required;

        emit RequirementChange(required);
    }

    // ... other necessary functions
}
