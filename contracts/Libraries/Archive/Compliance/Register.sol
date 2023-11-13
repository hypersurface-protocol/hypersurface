// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

library ShareRegister {

    // Events
    event ShareholderAdded(address shareholder);
    event ShareholderRemoved(address shareholder);

    // Define the Register struct to encapsulate the state variables
    struct RegisterStorage {
        address[] shareholders;
        mapping(address => uint256) shareholderIndices;
    }

    bytes32 constant REGISTER_POSITION = keccak256("register.storage");

    function getRegisterStorage() internal pure returns (RegisterStorage storage rs) {
        bytes32 position = REGISTER_POSITION;
        assembly {
            rs.slot := position
        }
    }

    // Shareholder management
    function addShareholder(address account) external {

        RegisterStorage storage register = getRegisterStorage();

        require(register.shareholderIndices[account] == 0, "Shareholder already exists");

        register.shareholders.push(account);
        register.shareholderIndices[account] = register.shareholders.length;

        emit ShareholderAdded(account);
    }

    function removeShareholder(address account) external {

        RegisterStorage storage register = getRegisterStorage();

        uint256 index = register.shareholderIndices[account];
        require(index != 0, "Shareholder does not exist");

        uint256 lastIndex = register.shareholders.length - 1;
        if (index - 1 != lastIndex) {
            address lastShareholder = register.shareholders[lastIndex];
            register.shareholders[index - 1] = lastShareholder;
            register.shareholderIndices[lastShareholder] = index;
        }

        register.shareholders.pop();
        delete register.shareholderIndices[account];

        emit ShareholderRemoved(account);
    }

    // Information getters
    function getShareholderAt(uint256 index) external view returns (address) {
        RegisterStorage storage register = getRegisterStorage();

        require(index < register.shareholders.length, "Index out of bounds");
        return register.shareholders[index];
    }

    function getShareholderCount() external view returns (uint256) {
        RegisterStorage storage register = getRegisterStorage();

        return register.shareholders.length;
    }
}