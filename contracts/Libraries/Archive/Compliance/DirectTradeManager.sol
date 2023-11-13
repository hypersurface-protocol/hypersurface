// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract DirectTradeManager {
	
    /// Events
    event TradeInitiated(
        bytes32 indexed tradeID,
        address indexed initiator,
        address indexed token1,
        uint256 amount1,
        address acceptor,
        address token2,
        uint256 amount2
    );

    event TradeExecuted(bytes32 indexed tradeID);

    event TradeCancelled(bytes32 indexed tradeID);

    event FeeUpdated(
        bytes32 indexed tokenPair,
        address token1,
        address token2,
        uint256 fee1,
        uint256 fee2,
        uint256 feePrecision,
        address fee1Recipient,
        address fee2Recipient
    );

    /// Types
    struct TradeDetail {
        address party;
        address token;
        uint256 amount;
    }

    struct TradeFee {
        uint256 primaryTokenFee;
        uint256 secondaryTokenFee;
        uint256 feePrecision;
        address primaryFeeRecipient;
        address secondaryFeeRecipient;
    }

    struct TradeFees {
        uint256 primaryFeeAmount;
        uint256 secondaryFeeAmount;
        address primaryFeeRecipient;
        address secondaryFeeRecipient;
    }

    struct TradeManagerStorage {
        mapping(bytes32 => TradeFee) tradeFees; // Fee details for a pair of tokens
        mapping(bytes32 => TradeDetail) initiatorTrades; // Trade details for the initiating party
        mapping(bytes32 => TradeDetail) acceptorTrades; // Trade details for the accepting party
        uint256 tradeNonce; // Nonce to ensure unique trade identifiers
    }

    TradeManagerStorage private _storage;

    /// Modifiers
    modifier onlyParticipant(bytes32 tradeID) {
        require(
            msg.sender == _storage.initiatorTrades[tradeID].party || 
            msg.sender == _storage.acceptorTrades[tradeID].party,
            "Not a participant of the trade"
        );
        _;
    }

    /// Constructor
    constructor() {
        _storage.tradeNonce = 0;
    }

    /// Functions
    function initiateTrade(
        address token1,
        uint256 amount1,
        address acceptor,
        address token2,
        uint256 amount2
    ) external {
        require(amount1 > 0 && amount2 > 0, "Trade amounts must be greater than 0");
        require(token1 != address(0) && token2 != address(0), "Invalid token address");
        require(acceptor != address(0), "Invalid acceptor address");

        bytes32 tradeID = calculateTradeID(msg.sender, token1, amount1, acceptor, token2, amount2);

        _storage.initiatorTrades[tradeID] = TradeDetail({
            party: msg.sender,
            token: token1,
            amount: amount1
        });

        _storage.acceptorTrades[tradeID] = TradeDetail({
            party: acceptor,
            token: token2,
            amount: amount2
        });

        _storage.tradeNonce++;

        emit TradeInitiated(tradeID, msg.sender, token1, amount1, acceptor, token2, amount2);
    }

    function executeTrade(bytes32 tradeID) external {
        require(
            msg.sender == _storage.initiatorTrades[tradeID].party || 
            msg.sender == _storage.acceptorTrades[tradeID].party,
            "Not a participant of the trade"
        );
        TradeDetail memory initiatorTrade = _storage.initiatorTrades[tradeID];
        TradeDetail memory acceptorTrade = _storage.acceptorTrades[tradeID];

        require(initiatorTrade.amount > 0 && acceptorTrade.amount > 0, "Trade not found");

        // Calculate fees and perform transfers (implementation needed)

        delete _storage.initiatorTrades[tradeID];
        delete _storage.acceptorTrades[tradeID];

        emit TradeExecuted(tradeID);
    }

    function cancelTrade(bytes32 tradeID) external {
        require(
            msg.sender == _storage.initiatorTrades[tradeID].party || 
            msg.sender == _storage.acceptorTrades[tradeID].party,
            "Not a participant of the trade"
        );
        delete _storage.initiatorTrades[tradeID];
        delete _storage.acceptorTrades[tradeID];

        emit TradeCancelled(tradeID);
    }

    function updateFee(
        address token1,
        address token2,
        uint256 fee1,
        uint256 fee2,
        uint256 feePrecision,
        address fee1Recipient,
        address fee2Recipient
    ) external {
        // Only the contract owner or other authorised roles should be able to update fees
        // Add appropriate access control (implementation needed)

        bytes32 tokenPair = calculateTokenPair(token1, token2);

        _storage.tradeFees[tokenPair] = TradeFee({
            primaryTokenFee: fee1,
            secondaryTokenFee: fee2,
            feePrecision: feePrecision,
            primaryFeeRecipient: fee1Recipient,
            secondaryFeeRecipient: fee2Recipient
        });

        emit FeeUpdated(tokenPair, token1, token2, fee1, fee2, feePrecision, fee1Recipient, fee2Recipient);
    }

    /// Helper Functions
    function calculateTradeID(
        address initiator,
        address token1,
        uint256 amount1,
        address acceptor,
        address token2,
        uint256 amount2
    ) private view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                _storage.tradeNonce,
                initiator,
                token1,
                amount1,
                acceptor,
                token2,
                amount2
            )
        );
    }

    function calculateTokenPair(address token1, address token2) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(token1, token2));
    }

    // Additional functions to handle fee calculations and token transfers
    // would be implemented here.
}
