// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

library TransferLimits {

    // Events for the transfer limits
    event ShareholderLimitUpdated(uint256 limit);
    event ShareholdingMinimumUpdated(uint256 minimum);
    event ShareholdingNonDivisibleUpdated(bool nonDivisible);
    event AccountFrozen(address indexed account, bool frozen);
    event SharesFrozen(address indexed account, uint256 amount);

    // Define a Limits struct to hold limit-related state variables
    struct LimitsStorage {
        uint256 shareholderLimit;
        uint256 shareholdingMinimum;
        bool shareholdingNonDivisible;
		mapping(address => bool) frozenAccounts;
		mapping(address => uint256) frozenShares;
    }

    bytes32 constant LIMITS_POSITION = keccak256("limits.storage");

    function getLimitsStorage() internal pure returns (LimitsStorage storage limits) {
        bytes32 position = LIMITS_POSITION;
        assembly {
            ls.slot := position
        }
    }

    // Functions for setting limits and freezing accounts
    function setShareholderLimit(uint256 limit) external {

        LimitsStorage storage limits = getLimitsStorage();

        limits.shareholderLimit = limit;
        emit ShareholderLimitUpdated(limit);
    }

    function setShareholdingMinimum(uint256 minimum) external {
		
		// Get limit storage
		LimitsStorage storage limits = getLimitsStorage();

        limits.shareholdingMinimum = minimum;
        emit ShareholdingMinimumUpdated(minimum);
    }

    function setShareholdingNonDivisible(bool nonDivisible) external {
		
		// Get limit storage
		LimitsStorage storage limits = getLimitsStorage();

        limits.shareholdingNonDivisible = nonDivisible;
        emit ShareholdingNonDivisibleUpdated(nonDivisible);
    }

    function freezeAccount(address account, bool freeze) external {
		
		// Get limit storage
		LimitsStorage storage limits = getLimitsStorage();

        frozenAccounts[account] = freeze;
        emit AccountFrozen(account, freeze);
    }

    function freezeSharesForAccount(address account, uint256 amount) external notFrozen(account) {
		
		// Get limit storage
		LimitsStorage storage limits = getLimitsStorage();

		require(!frozenAccounts[account], "Account is frozen");
        require(amount <= _share.balanceOf(account) - frozenShares[account], "Insufficient unfrozen shares");
        frozenShares[account] += amount;
        emit SharesFrozen(account, amount);
    }

    // Functions for checking transfer eligibility

    /**
     * @dev Checks if a transfer is allowed based on the shareholder limit.
     * @return bool representing whether the transfer is allowed.
     */
    function checkWithinShareholderLimit() public view returns (bool) {
		
		// Get limit storage
		LimitsStorage storage limits = getLimitsStorage();

        return _shareholders.length < limits.shareholderLimit;
    }

    /**
     * @dev Checks if a transfer is allowed based on the shareholding minimum.
     * @param from The sender's address.
     * @param to The recipient's address.
     * @param amount The amount being transferred.
     * @return bool representing whether the transfer is allowed.
     */
    function checkMinimumShareholding(address from, address to, uint256 amount) public view returns (bool) {
		
		// Get limits storage
		LimitsStorage storage limits = getLimitsStorage();

        uint256 balanceFrom = _share.balanceOf(from);
        uint256 balanceTo = _share.balanceOf(to);

        // Check if sender balance will stay above minimum after transfer
        if (from != address(0) && balanceFrom > 0) {

            if (balanceFrom - amount < limits.shareholdingMinimum) {
                return false;
            }
        }

        // Check if recipient balance will meet minimum after transfer
        if (to != address(0)) {
            if (balanceTo + amount < limits.shareholdingMinimum) {
                return false;
            }
        }

        return true;
    }

    /**
     * @dev Checks if a transfer is allowed based on the divisibility of shares.
     * @param amount The amount being transferred.
     * @return bool representing whether the transfer is allowed.
     */
    function checkNonDivisibleTransfer(uint256 amount) public view returns (bool) {
        if (limits.shareholdingNonDivisible) {
            // Assuming shares are represented in the smallest unit and are indivisible.
            return amount % 1 ether == 0;
        }
        return true;
    }

    /**
     * @dev Checks if the accounts involved in the transfer are not frozen.
     * @param from The sender's address.
     * @param to The recipient's address.
     * @return bool representing whether the transfer is allowed.
     */
    function checkNotFrozenTransfer(address from, address to) public view returns (bool) {
        return !frozenAccounts[from] && !frozenAccounts[to];
    }

    /**
     * @dev Checks if the transfer does not involve frozen shares.
     * @param from The sender's address.
     * @param amount The amount being transferred.
     * @return bool representing whether the transfer is allowed.
     */
    function checkSufficientUnfrozenShares(address from, uint256 amount) public view returns (bool) {
        uint256 balance = _share.balanceOf(from);
        uint256 frozen = frozenShares[from];

        return balance - frozen >= amount;
    }
}
