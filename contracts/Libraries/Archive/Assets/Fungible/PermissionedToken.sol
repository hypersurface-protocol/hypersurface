// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

// Inheriting
import '../interface/IPermissionToken.sol';
import "openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

// Interfaces
import '../interface/IPermissionTokenCompliance.sol';
import '../interface/IPermissionTokenRegistry.sol';

/**
    TODO To be formatted.
 */

/**

    PermissionToken is an ERC1155 based tokenised equity contract. It provides all the functions
    traditionally associated with an ERC1155 token contract, plus additional issuer controls
    designed (and legally required in some jurisdictions) to support equity shares. These
    features include forced transfers and share recovery in the event that a shareholder has 
    lost access to their wallet.

    PermissionToken also features a sophisticated suite of compliance checks via its peripheral 
    contracts and the broader Hypersurface protocol. These checks are intended to reduce the 
    burden on token issuers while helping to increase asset transferability, with the view of 
    creating a liquid, highly-automated secondary market for equity shares.

    Although PermissionToken was designed with the objective of providing an open and accesible 
    platform for equity tokenisation, the contracts themselves are flexible enough to support
    almost any type of real world asset. 

 */

contract PermissionToken is IPermissionToken, ERC1155, ERC1155Pausable, Ownable {

    ////////////////
    // INTERFACES
    ////////////////

    /**
     * @dev The compliance claims checker contract. 
     */
    IPermissionTokenCompliance public _compliance;

    /**
     * @dev The shareholder registry for this PermissionToken contract.
     */
    IPermissionTokenRegistry public _registry;

    ////////////////
    // STATE
    ////////////////

    /**
     * @dev Total tokens, incremented value used to get the most recent/next token ID.
     */
    uint256 _totalTokens;

    ////////////////
    // CONSTRUCTOR
    ////////////////

    constructor(
		string memory uri_,
        address compliance,
        address registry
    )
        // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
        ERC1155(uri_)
    {
        // Set compliance
        setCompliance(compliance);

    	// Set registry
	    setRegistry(registry);
    }

    ////////////////
    // MODIFIERS
    ////////////////

    /**
     * @dev Prevents token transfers to the zero address.
     * @param to The receiving address.
     */
    modifier transferToZeroAddress(
        address to
    ) {
        if (to == address(0))
            revert TransferToZeroAddress();
        _;
    }

    /**
     * @dev Ensures the sender has sufficient tokens for a token transfer.
     * @param from The transfering address. 
     * @param id The id of the token transfer.
     * @param amount The amount of tokens to transfer.
     */
    modifier sufficientTokens(
        address from,
        uint256 id,
        uint256 amount
    ) {
        if (from != address(0))
            if (balanceOf(from, id) <= amount)
                revert InsufficientTokens();
        _;
    } 

    /**
     * @dev Ensures that the array of accounts and amounts are of equal length.
     * @param accounts An array of user addresses.
     * @param amounts An array of the integer amounts.
     */
    modifier equalAccountsAmounts(
        address[] memory accounts,
        uint256[] memory amounts
    ) {
        if (accounts.length != amounts.length)
            revert UnequalAccountsAmounts();
        _;
    }

    /**
     * @dev Ensures that mint amount is non-zero.
     * @param amount The amount of token transfer.
     */
    modifier mintZeroTokens(
        uint256 amount
    ) {
        if (amount == 0)
            revert MintZeroTokens();
        _;
    }

    //////////////////////////////////////////////
    // CREATE NEW TOKEN
    //////////////////////////////////////////////

    /**
     * @dev Create a new token by incrementing token ID and initizializing in the compliance contracts.
     * @param shareholderLimit The maxium number of shareholders. 
     * @param shareholdingMinimum The minimum amount of shares per shareholder. 
     * @param shareholdingNonDivisible The boolean value as to if the share type is non-divisible. 
     */
    function newToken(
        uint256 shareholderLimit,
        uint256 shareholdingMinimum,
        bool shareholdingNonDivisible
    )
        public
        onlyOwner
        returns (uint256)
    {
        // Increment tokens
        _totalTokens++;

        // Register the new token
        _registry.newToken(_totalTokens, shareholderLimit, shareholdingMinimum, shareholdingNonDivisible);

        // Event
        emit NewToken(_totalTokens, shareholderLimit, shareholdingMinimum, shareholdingNonDivisible);

        return _totalTokens;
    }

    //////////////////////////////////////////////
    // TRANSFERS
    //////////////////////////////////////////////

    /**
     * @dev Pre validate the token transfer to ensure that the actual transfer will not fail under
       the same conditions. 
     *
     * @param from The transfering address. 
     * @param to The receiving address. 
     * @param id The id of the token transfer.
     * @param amount The amount of tokens to transfer.
     * @param data Optional data field to include in events.
     */
	function checkTransferIsValid(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        transferToZeroAddress(to)
        sufficientTokens(from, id, amount)
        returns (bool)
    {
        uint256[] memory ids = new uint256[](1);
        ids[0] = id;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        _beforeTokenTransfer(_msgSender(), from, to, ids, amounts, data);

		return true;
	}
	
    /** 
     * @dev Owner-operator function to force a batch transfer from an address. May be used to burn
     * and reissue if the share terms are updated.
     *
     * @param from The transfering address. 
     * @param to The receiving address. 
     * @param ids An array of token IDs for the token transfer.
     * @param amounts An array of integer amounts for each token in the token transfer.
     * @param data Optional data field to include in events.
     */
    function forcedBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
		public
		virtual
		override 
		onlyOwner
	{
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /** 
     * @dev Owner-operator function used to force a transfer from an address. Typically used in the
     * case of share recovery.
     *
     * @param from The transfering address. 
     * @param to The receiving address. 
     * @param id The id of the token transfer.
     * @param amount The amount of tokens to transfer.
     * @param data Optional data field to include in events.
     */
	function forcedTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
	)
		public
		virtual
		override 
		onlyOwner
	{
		_safeTransferFrom(from, to, id, amount, data);
	}

    /** 
     * @dev Owner-operator function to burn and reissue shares in the event of a lost wallet.
     * @param lostWallet The address of the wallet that contains the shares for reissue.
     * @param newWallet The address of the wallet that reissued shares should be sent to.
     * @param data Optional data field to include in events.
    */
	function recover(
        address lostWallet,
        address newWallet,
        bytes memory data
    )
        external
        onlyOwner 
        returns (bool)
    {
        _registry.setFrozenAll(newWallet, _registry.checkNotFrozenAll(lostWallet));
    
        // For all tokens 
        for (uint256 id = 0; id < _totalTokens; id++) {
            
            // If user has balance for tokens
            if (balanceOf(lostWallet, id) > 0) {

                // Transfer tokens from old account to new one
                forcedTransferFrom(lostWallet, newWallet, id, balanceOf(lostWallet, id), data);

                // Freeze partial shares
                uint256 frozenShares = _registry.getFrozenShares(lostWallet, id);

                // If has frozen shares freeze on new account
                if (frozenShares > 0) 
                    _registry.freezeShares(id, newWallet, frozenShares);
                
            }
        }
        
        // Event
        emit RecoverySuccess(lostWallet, newWallet);

        return true;
    }

    //////////////////////////////////////////////
    // HOOKS
    //////////////////////////////////////////////

    /**
     * @dev ERC-1155 before transfer hook. Used to validate the transfer with the compliance contracts. 
     * @param operator The address of the contract owner/operator.
     * @param from The transfering address. 
     * @param to The receiving address. 
     * @param ids An array of token IDs for the token transfer.
     * @param amounts An array of integer amounts for each of the token IDs in the token transfer.
     * @param data Optional data field to include in events.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
		internal
		override(ERC1155, ERC1155Pausable)
	{
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        
        // Ensure that the receiver has the required claims.
        if (address(_compliance) != address(0))
            if (!_compliance.checkTransferBatchElligible(to, from, ids, amounts))
                revert RecieverInelligible();

        // Ensure that the transfer does not violate any of the transfer limits.
        if (address(_registry) != address(0))
            if (!_registry.checkTransferBatchElligible(to, from, ids, amounts))
                revert TransferInelligible();
	}

    /**
     * @dev ERC-1155 after transfer hook. Used to update the shareholder registry to reflect the transfer. 
     * @param operator The address of the contract owner/operator.
     * @param from The transfering address. 
     * @param to The receiving address. 
     * @param ids An array of token IDs for the token transfer.
     * @param amounts An array of integer amounts for each of the token IDs in the token transfer.
     * @param data Optional data field to include in events.
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
		internal
		override(ERC1155)
	{
        if (address(_registry) != address(0))
            if (!_registry.batchTransferred(from, to, ids, amounts))
                revert CouldNotUpdateShareholders();
	}

    //////////////////////////////////////////////
    // MINT AND BURN 
    //////////////////////////////////////////////

    /**
     * @dev Mint shares to a group of receiving addresses. 
     * @param accounts An array of the recieving accounts.
     * @param id The token ID to mint.
     * @param amounts An array of the amount to mint to each receiver.
     * @param data Optional data field to include in events.
     */
    function mintGroup(
        address[] memory accounts,
        uint256 id,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        onlyOwner
        equalAccountsAmounts(accounts, amounts)
    {
        for (uint256 i = 0; i < accounts.length; i++)
            mint(accounts[i], id, amounts[i], data);
    }
    
    /**
     * @dev Mint shares to a receiving address. 
     * @param account The receiving address.
     * @param id The token ID to mint.
     * @param amount The amount of shares to mint to the receiver.
     * @param data Optional data field to include in events.
     */
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        onlyOwner
        transferToZeroAddress(account)
        mintZeroTokens(amount)
    {
        // Mint
        _mint(account, id, amount, data);

        // Updates
        _registry.mint(account, id, amount);  

        // Event
        emit MintTokens(account, id, amount, data);
    }

    /**
     * @dev Burn shares from a group of shareholder addresses. 
     * @param accounts An array of the accounts to burn shares from.
     * @param id The token ID to burn.
     * @param amounts An array of the amounts of shares to burn from each account.
     * @param data Optional data field to include in events.
     */
    function burnGroup(
        address[] memory accounts,
        uint256 id,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        onlyOwner
        equalAccountsAmounts(accounts, amounts)
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            burn(accounts[i], id, amounts[i], data );
        }
    }

    /**
     * @dev Burn shares from a shareholder address. 
     * @param account The account shares are being burnt from.
     * @param id The token ID to mint to receiver.
     * @param amount The amount of tokens to burn from the account.
     * @param data Optional data field to include in events.
     */
    function burn(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        onlyOwner
    {
        // Burn
        _burn(account, id, amount);

        // Updates
        _registry.burn(account, id, amount);

        // Event
        emit BurnTokens(account, id, amount, data);
    }

    //////////////////////////////////////////////
    // SETTERS
    //////////////////////////////////////////////

    /** 
     * @dev Set the address of the compliance contract. Complaince checks the claims of the receiver to
     * ensure their elligibility.
     *
     * @param compliance The new compliance contract address. 
     */
    function setCompliance(
        address compliance
    ) 
        public 
        onlyOwner
    {
        _compliance = IPermissionTokenCompliance(compliance);
        
        emit UpdatedPermissionTokenCompliance(compliance);  
    }

    /** 
     * @dev Set the address of the registry contract. Registry records the token shareholders on chain 
     * and enforces limit-based transfer restrictions.
     *
     * @param registry The new registry contract address. 
     */
	function setRegistry(
        address registry
    )
        public
        onlyOwner
    {
        _registry = IPermissionTokenRegistry(registry);
        
        emit UpdatedPermissionTokenRegistry(registry);  
    }

    //////////////////////////////////////////////
    // GETTERS
    //////////////////////////////////////////////

    /** 
     * @dev Returns the total token count where token IDs are incremental values.
     */
    function getTotalTokens()
        public
        view 
        returns (uint256)
    {
        return _totalTokens;
    }

}