// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./PriceFeedConsumer.sol";

/**
 * @title The Portfolio contract
 * @notice A contract to manage a portfolio of assets
 */
contract Portfolio {
    struct Asset {
        uint256 balance;
        uint256 proportion;
    }
    mapping(string => Asset) public assets; // symbols => balance
    string[] public symbols; // symbols
    address public owner; // owner of the portfolio
    PriceFeedConsumer internal priceFeeds; // price feed consumer (chainlink)

    struct Swaps {
        string symbol;
        uint256 amount;
        bool isBuy;
    } 

    constructor(string memory _symbol, uint256 _balance, address _priceFeed) {
        // Set portfolio's owner
        owner = msg.sender;

        // Add first asset to the portfolio
        priceFeeds = new PriceFeedConsumer(_symbol, _priceFeed);
        assets[_symbol].balance = _balance;
        symbols.push(_symbol);
    }

    /**
     * @notice Adds a new asset to the portfolio
     *
     */
    function addAsset(string memory _symbol, uint256 _balance, address _priceFeed) ownerOnly assetDoesNotExist(_symbol) public {
        priceFeeds.addPriceFeed(_symbol, _priceFeed);
        assets[_symbol].balance = _balance;
        symbols.push(_symbol);
    }

    /**
     * @notice Change asset balance to the portfolio
     *
     */
    function changeAssetBalance(string memory _symbol, uint256 _change, bool _isAddition) ownerOnly assetExists(_symbol) public {
        // if addition is true, add the change to the balance
        if (_isAddition) {
            assets[_symbol].balance += _change;
        // if the change is less than the balance, substract the change from the balance
        } else if (assets[_symbol].balance > _change) {
            assets[_symbol].balance -= _change;
        // otherwise, set the balance to 0
        } else {
            assets[_symbol].balance = 0;
        }

        // If the asset balance is 0, remove the asset from the portfolio
        if (assets[_symbol].balance == 0) {
            // Remove the asset's price feed
            priceFeeds.removePriceFeed(_symbol);

            // Remove the asset from the assets array
            for (uint256 i = 0; i < symbols.length; i++) {
                if (keccak256(abi.encodePacked(symbols[i])) == keccak256(abi.encodePacked(_symbol))) {
                    symbols[i] = symbols[symbols.length - 1];
                    symbols.pop();
                    break;
                }
            }
        }
    }

    /**
     * @notice Returns the portfolio value
     *
     * @return portfolio value
     */
    function getPortfolioValue() public view returns (uint256) {
        uint256 portfolioValue = 0;
        for (uint256 i = 0; i < symbols.length; i++) {
            // Get the asset price, multiply by the balance, and add to the portfolio value
            portfolioValue += uint256(priceFeeds.getLatestPrice(symbols[i])) * assets[symbols[i]].balance;
        }
        return portfolioValue;
    }

    /**
     * @notice Returns the asset value
     *
     * @return asset balance
     */
    function getAssetValue(string memory _symbol) assetExists(_symbol) public view returns (uint256) {
        // Get the asset price, multiply by the balance, and add to the portfolio value
        return uint256(priceFeeds.getLatestPrice(_symbol)) * assets[_symbol].balance;
    }

    /** 
     * @notice Swap an asset for another
     *
     */
    function swapAsset(string memory _symbol, uint256 _amount, bool _isBuy) private {
          // TODO: Buy or sell the balance of the asset
          // If buy is true, then 
    }

    /**
     * @notice Rebalance the portfolio
     *
     */
    function rebalance() public {
        // Get the portfolio value
        uint256 portfolioValue = getPortfolioValue();
        uint256 factor = 100;
        Swaps[] memory buys = new Swaps[](symbols.length);
        uint64 buysLen = 0;

        // Calculate the proportion of each asset and rebalance
        for (uint256 i = 0; i < symbols.length; i++) {
            uint256 requiredValue =  portfolioValue * factor / assets[symbols[i]].proportion;
            uint256 currentValue = getAssetValue(symbols[i]);
            
            // If the current value is equal to the required value, no need to rebalance the asset
            if (currentValue == requiredValue) continue;
            
            uint256 amount = 0;
            bool isSell = true;
            
            // Calculate the difference (amount) between the current value and the required value
            if (currentValue > requiredValue) {
                amount = currentValue - requiredValue;
            } else if (currentValue < requiredValue) {
                amount = requiredValue - currentValue;
                isSell = false;
            }

            if (isSell) {
                swapAsset(buys[i].symbol, amount, true);
                changeAssetBalance(symbols[i], amount, true);
            } else {
                // add the asset to the buys array
                buys[buysLen] = Swaps(symbols[i], amount, true);
                buysLen++;
            }
        }
        
        if (buysLen == 0) return;

        for (uint256 i = 0; i < buysLen; i++) {
            swapAsset(buys[i].symbol, buys[i].amount, true);
            changeAssetBalance(symbols[i], buys[i].amount, true);
        }
    }

    modifier ownerOnly() {
        require(msg.sender == owner, "Only the owner of the portfolio can call this function.");
        _;
    }

    modifier assetExists(string memory _symbol) {
        require(assets[_symbol].balance > 0, "Asset does not exist in the portfolio.");
        _;
    }

    modifier assetDoesNotExist(string memory _symbol) {
        require(assets[_symbol].balance == 0, "Asset already exists in the portfolio.");
        _;
    }
}