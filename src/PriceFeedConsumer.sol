// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title The PriceConsumerV3 contract
 * @notice A contract that returns latest price from Chainlink Price Feeds
 */
contract PriceFeedConsumer {
    mapping(string => AggregatorV3Interface) internal priceFeeds;

    constructor(string memory _symbol, address _priceFeed) {
        priceFeeds[_symbol] = AggregatorV3Interface(_priceFeed);
    }

    /**
     * @notice Adds a new price feed to the contract
     *
     */
    function addPriceFeed(string memory _symbol, address _priceFeed) priceFeedNotExists(_symbol) public {
        priceFeeds[_symbol] = AggregatorV3Interface(_priceFeed);
    }

    /**
     * @notice Removes a price feed from the contract
     *
     */
    function removePriceFeed(string memory _symbol) priceFeedExists(_symbol) public {
        delete priceFeeds[_symbol];
    }

    /**
     * @notice Returns the latest price
     *
     * @return latest price
     */
    function getLatestPrice(string memory _symbol) priceFeedExists(_symbol)
        public
        view
        returns (int256)
    {
        (, int256 price, , , ) = priceFeeds[_symbol].latestRoundData();
        return price;
    }

    /**
     * @notice Returns the Price Feed address
     *
     * @return Price Feed address
     */
    function getPriceFeed(string memory _symbol) priceFeedExists(_symbol) public view returns (AggregatorV3Interface) {
        return priceFeeds[_symbol];
    }

    modifier priceFeedExists(string memory _symbol) {
        require(
            priceFeeds[_symbol] != AggregatorV3Interface(address(0)),
            "Price feed does not exist."
        );
        _;
    }

    modifier priceFeedNotExists(string memory _symbol) {
        require(
            priceFeeds[_symbol] == AggregatorV3Interface(address(0)),
            "Price feed already exists."
        );
        _;
    }
}
