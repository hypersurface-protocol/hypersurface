// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

library Dividends {

    ////////////////
    // STATES
    ////////////////

    struct DividendsStorage {
        uint256 totalShares; // Total shares held by all payees
        address[] shareholders; // Array of all shareholders
        mapping(address => uint256) shares; // Mapping from payee address to shares held by payee
        mapping(address => uint256) totalReleased; // Mapping from token address to total released (0x00 for ETH)
        mapping(address => mapping(address => uint256)) released; // Nested mapping from payee address to token address to amount released (0x00 for ETH)
    }

    bytes32 constant DIVIDEND_POSITION = keccak256("dividends.storage");

    function getDividendsStorage() internal pure returns (DividendsStorage storage ds) {
        bytes32 position = DIVIDEND_POSITION;
        assembly {
            ds.slot := position
        }
    }

    ////////////////
    // INIT
    ////////////////

    /**
     * @dev Creates an instance of `Dividends` where each payee in `payees` is assigned the number of shares at.
     * the matching position in the `shares` array.
     *
     * All addresses in `payees` must be non-zero. Both arrays must have the same non-zero length, and there must be no.
     * duplicates in `payees`.
     * @param payees The addresses of the payees.
     * @param shares The shares of each of the payees.
     */
    function initialize(
		address[] memory payees,
		uint256[] memory shares
	)
        public
        payable
    {
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();
        
        if (payees.length != shares.length)
            revert UnequalPayeesShares();
        if (0 < _totalShares)
            revert AlreadyInitialized();
        // Iterate through adding payees to the splitter
        for (uint256 i = 0; i < payees.length; i++)
            _addPayee(payees[i], shares[i]);
    }

    //////////////////////////////////////////////
    // RELEASE FUNCTIONS
    //////////////////////////////////////////////

    /**
     * @dev Triggers a transfer to `payee` of the amount of funds they are owed, according to their percentage of the.
     * total shares and their previous withdrawals.
     * @param token The address of the token for the query (if applicable, otherwise 0x000...).
     * @param payee The address of the payee who's balance is being queried.
     */
    function release(
        address token,
        address payee
    )
        public
        virtual
    {
     
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();

        // Sanity checks
        if (_shares[payee] == 0)
            revert PayeeNotExists(payee);

        // Calculate payee funds owed
        uint256 payment = getBalanceOf(token, payee);
        
        if (payment == 0)
            revert NotDuePayment(address(this), payee);

        // Release funds
        _release(token, payee, payment);
        
        // Emit event
        emit PaymentReleased(token, payee, payment);
    }

    //////////////////////////////////////////////
    // GETTERS
    //////////////////////////////////////////////

    /**
     * @dev Getter helper for the current balance of the splitter.
     * @param token The token address for the balance query (if applicable, otherwise 0x000...).
     */
    function getSplitterBalance(
        address token
    )
        public
        view
        returns (uint256)
    {
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();

        if (token == address(0))
            return address(this).balance;
        else 
            return IERC20(token).balanceOf(address(this));
    }

    /**
     * @dev Getter for the address of the payee number `index`.
     * @param index The index of the payee index who address is being queried.
     */
    function getPayeeAddress(
        uint256 index
    )
        public
        view
        returns (address)
    {
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();
        
        return _shareholders[index];
    }

    /**
     * @dev Return the number of payees on the contract.
     */
    function getPayeesLength()
        public
        view
        returns (uint256)
    {
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();
        
        return _shareholders.length;
    }

    /**
     * @dev Getter for the amount of shares held by an payee.
     * @param payee The address of the payee who's balance is being queried.
     */
    function getShares(
        address payee
    )
        public
        view
        returns (uint256)
    {
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();
        
        return _shares[payee];
    }

    /**
     * @dev Getter for the total shares held by payees.
     */
    function getTotalShares()
        public
        view
        returns (uint256)
    {
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();
        
        return _totalShares;
    }

    /**
     * @dev Getter for the payees on the splitter contract. Returns an array of the addresses of all payees.
     */
    function getAllPayees()
        public
        view
        returns (address[] memory)
    {
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();
        
        return _shareholders;   
    }

    /**
     * @dev Getter for the shares on the splitter contract. Returns an array of amounts of all shares.
     */
    function getAllShares()
        public
        view
        returns (uint256[] memory shares_)
    {
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();
        
        shares_ = new uint256[](_shareholders.length);
        
        // Iterate through returning balances
        for (uint8 i = 0; i < _shareholders.length; i++)
            shares_[i] = _shares[_shareholders[i]];
    }

    /**
     * @dev Getter for the releasable balance of payee.
     * @param token The token address for releasable tokens (if applicable, otherwise 0x000...).
     * @param payee The address of the payee who's balance is being queried.
     */
    function getBalanceOf(
        address token,
        address payee
    )
        public
        view
        returns (uint256 payment_)
    {
        payment_ = _pendingPayment(payee, (getSplitterBalance(token) + _totalReleased[token]), _released[token][payee]);
    }

    /**
     * @dev Getter for the releasable balances of all payees.
     * @param token The token address for the erc20 releasable balance query  (if applicable, otherwise 0x000...).
     */
    function getBalances(
        address token
    )  
        public
        view 
        returns (uint256[] memory balances_)
    {
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();
        
        // Create uint256 array of size payees.length
        balances_ = new uint256[](_shareholders.length);
        
        // Iterate through returning balances
        for (uint8 i = 0; i < _shareholders.length; i++)
            balances_[i] = getBalanceOf(token, _shareholders[i]);
    }

    /**
     * @dev Getter for the total amount of funds already released.
     * @param token The address of the token for the query (if applicable, otherwise 0x000...).
     */
    function getTotalReleased(
        address token
    )
        public
        view
        returns (uint256)
    {
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();
        
        return _totalReleased[token];
    }

    /**
     * @dev Getter for the amount of funds already released to a payee.
     * @param token The address of the token for the query (if applicable, otherwise 0x000...).
     * @param payee The address of the payee who's balance is being queried.
     */
    function getReleased(
        address token,
        address payee
    )
        public
        view
        returns (uint256)
    {
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();
        
        return _released[token][payee];
    }

    //////////////////////////////////////////////
    // INTERNAL FUNCTIONS
    //////////////////////////////////////////////

    /**
     * @dev internal logic for computing the pending payment of an `payee` given the token historical balances and.
     * already released amounts.
     * @param payee The address of the payee.
     * @param totalReceived The total amount recieved by the payee .
     * @param alreadyReleased The total amount already released to the payee.
     */
    function _pendingPayment(
        address payee,
        uint256 totalReceived,
        uint256 alreadyReleased
    )
        internal
        view
        returns (uint256)
    {
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();
        
        return (totalReceived * _shares[payee]) / _totalShares - alreadyReleased;
    }

    /**
     * @dev Add a new payee to the contract.
     * @param payee The address of the payee to add.
     * @param shares The number of shares owned by the payee.
     */
    function _addPayee(
        address payee,
        uint256 shares
    )
        internal
    {
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();
        
        // Sanity checks
        if (payee == address(0))
            revert PayeeIsZeroAddress();
        if (shares == 0)
            revert NoShares();
        if (_shares[payee] != 0)
            revert PayeeExists(payee);

        // Add the payee
        _shareholders.push(payee);
        _shares[payee] = shares;
        _totalShares = _totalShares + shares;

        // Emit event
        emit PayeeAdded(payee, shares);
    }

    /**
     * @dev Release funds or tokens to a payee.
     * @param token The address of the token to transfer (if applicable, otherwise 0x000...).
     * @param payee The address of the payee to transfer funds to.
     * @param amount The amount of funds to transfer to the payee.
     */
    function _release(
        address token,
        address payee,
        uint256 amount
    )
        internal
    {
        // Get compliance from storage
        DividendsStorage storage compliance = getDividendsStorage();
        
        // Update released
        _released[token][payee] += amount;
        _totalReleased[token] += amount;

        if (token == address(0))
            payable(payee).transfer(amount);
        else 
            SafeERC20.safeTransfer(IERC20(token), payee, amount);  
    }

}