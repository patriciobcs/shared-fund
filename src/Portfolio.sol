// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./PriceFeedConsumer.sol";

/**
 * @title The Portfolio contract
 * @notice A contract to manage a portfolio of assets
 */
contract Portfolio {
    mapping(string => uint256) public balances; // symbols => balance
    string[] public assets; // symbols
    address public owner; // owner of the portfolio
    PriceFeedConsumer internal priceFeeds; // price feed consumer (chainlink)

    constructor(string memory _symbol, uint256 _balance, address _priceFeed) {
        // Set portfolio's owner
        owner = msg.sender;

        // Add first asset to the portfolio
        priceFeeds = new PriceFeedConsumer(_symbol, _priceFeed);
        balances[_symbol] = _balance;
        assets.push(_symbol);
    }

    /**
     * @notice Adds a new asset to the portfolio
     *
     */
    function addAsset(string memory _symbol, uint256 _balance, address _priceFeed) ownerOnly assetDoesNotExist(_symbol) public {
        priceFeeds.addPriceFeed(_symbol, _priceFeed);
        balances[_symbol] = _balance;
        assets.push(_symbol);
    }

    /**
     * @notice Change asset balance to the portfolio
     *
     */
    function changeAssetBalance(string memory _symbol, uint256 _change, bool _addition) ownerOnly assetExists(_symbol) public {
        // if addition is true, add the change to the balance
        if (_addition) {
            balances[_symbol] += _change;
        // if the change is less than the balance, substract the change from the balance
        } else if (balances[_symbol] > _change) {
            balances[_symbol] -= _change;
        // otherwise, set the balance to 0
        } else {
            balances[_symbol] = 0;
        }

        // If the asset balance is 0, remove the asset from the portfolio
        if (balances[_symbol] == 0) {
            // Remove the asset's price feed
            priceFeeds.removePriceFeed(_symbol);

            // Remove the asset from the assets array
            for (uint256 i = 0; i < assets.length; i++) {
                if (keccak256(abi.encodePacked(assets[i])) == keccak256(abi.encodePacked(_symbol))) {
                    assets[i] = assets[assets.length - 1];
                    assets.pop();
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
        for (uint256 i = 0; i < assets.length; i++) {
            // Get the asset price, multiply by the balance, and add to the portfolio value
            portfolioValue += uint256(priceFeeds.getLatestPrice(assets[i])) * balances[assets[i]];
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
        return uint256(priceFeeds.getLatestPrice(_symbol)) * balances[_symbol];
    }

    modifier ownerOnly() {
        require(msg.sender == owner, "Only the owner of the portfolio can call this function.");
        _;
    }

    modifier assetExists(string memory _symbol) {
        require(balances[_symbol] > 0, "Asset does not exist in the portfolio.");
        _;
    }

    modifier assetDoesNotExist(string memory _symbol) {
        require(balances[_symbol] == 0, "Asset already exists in the portfolio.");
        _;
    }
}