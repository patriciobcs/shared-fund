// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "openzeppelin-contracts/access/Ownable.sol";

/**
 * @title The PriceConsumerV3 contract
 * @notice A contract that returns latest price from Chainlink Price Feeds
 */
contract PriceFeedConsumer is Ownable {
    mapping(address => AggregatorV3Interface) internal priceFeeds;

    constructor(address _token, address _priceFeed) {
        priceFeeds[_token] = AggregatorV3Interface(_priceFeed);
    }

    /**
     * @notice Adds a new price feed to the contract
     *
     */
    function addPriceFeed(address _token, address _priceFeed) public priceFeedDoesNotExists(_token) onlyOwner {
        priceFeeds[_token] = AggregatorV3Interface(_priceFeed);
    }

    /**
     * @notice Removes a price feed from the contract
     *
     */
    function removePriceFeed(address _token) public priceFeedExists(_token) onlyOwner {
        delete priceFeeds[_token];
    }

    /**
     * @notice Returns the latest price
     *
     * @return latest price
     */
    function getLatestPrice(address _token) public view priceFeedExists(_token) returns (int256) {
        (, int256 price,,,) = priceFeeds[_token].latestRoundData();
        return price;
    }

    /**
     * @notice Returns the Price Feed address
     *
     * @return Price Feed address
     */
    function getPriceFeed(address _token) public view priceFeedExists(_token) returns (AggregatorV3Interface) {
        return priceFeeds[_token];
    }

    modifier priceFeedExists(address _token) {
        require(priceFeeds[_token] != AggregatorV3Interface(address(0)), "Price feed does not exist.");
        _;
    }

    modifier priceFeedDoesNotExists(address _token) {
        require(priceFeeds[_token] == AggregatorV3Interface(address(0)), "Price feed already exists.");
        _;
    }
}
