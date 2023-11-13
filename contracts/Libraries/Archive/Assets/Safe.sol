// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
    TODO to be formatted
 */

contract SAFEAgreement {
    
    struct SafeStorage {
        address issuer;
        uint256 valuationCap;
        uint256 discountRate;
        bool isConverted;
    }

    struct InvestorDetails {
        uint256 amountInvested;
        bool hasConverted;
    }

    SafeStorage public safe;
    mapping(address => InvestorDetails) public investors;
    uint256 public totalInvestment;

    event InvestmentReceived(address investor, uint256 amount);
    event EquityConverted(address investor, uint256 amountInvested);

    modifier onlyIssuer() {
        require(msg.sender == safe.issuer, "Only issuer can call this.");
        _;
    }

    modifier notConverted() {
        require(!safe.isConverted, "SAFE has already been converted.");
        _;
    }

    constructor(uint256 _valuationCap, uint256 _discountRate) {
        require(_valuationCap > 0, "Valuation cap must be positive.");
        require(_discountRate > 0 && _discountRate <= 100, "Invalid discount rate.");
        
        safe.issuer = msg.sender;
        safe.valuationCap = _valuationCap;
        safe.discountRate = _discountRate;
        safe.isConverted = false;
    }

    function invest() external payable notConverted {
        require(msg.value > 0, "Investment must be greater than 0.");
        investors[msg.sender].amountInvested += msg.value;
        totalInvestment += msg.value;
        emit InvestmentReceived(msg.sender, msg.value);
    }

    function convertToEquity(uint256 _equityFinancingValuation) external onlyIssuer notConverted {
        require(_equityFinancingValuation > 0, "Equity valuation must be positive.");
        require(_equityFinancingValuation >= safe.valuationCap, "Valuation must be at or above the cap.");
        safe.isConverted = true;

        for (uint256 i = 0; i < investors.length; i++) {
            address investorAddr = investors[i];
            InvestorDetails storage investor = investors[investorAddr];

            if (!investor.hasConverted) {
                uint256 investment = investor.amountInvested;
                uint256 conversionPrice = calculateConversionPrice(_equityFinancingValuation);
                uint256 shares = investment / conversionPrice;
                
                // Assuming the conversion would involve transferring shares or tokens
                // transferShares(investorAddr, shares);
                
                investor.hasConverted = true;
                emit EquityConverted(investorAddr, investment);
            }
        }
    }

    function calculateConversionPrice(uint256 _equityFinancingValuation) public view returns (uint256) {
        uint256 pricePerShareBasedOnCap = safe.valuationCap / totalInvestment; // This assumes 1:1 SAFE to share conversion
        uint256 pricePerShareBasedOnDiscount = (_equityFinancingValuation * (100 - safe.discountRate)) / (100 * totalInvestment);

        return pricePerShareBasedOnCap < pricePerShareBasedOnDiscount ? pricePerShareBasedOnCap : pricePerShareBasedOnDiscount;
    }

    // Additional functions and safety checks can be implemented as needed.
}
