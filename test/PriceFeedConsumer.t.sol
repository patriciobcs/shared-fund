// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../src/PriceFeedConsumer.sol";
import "./mocks/MockV3Aggregator.sol";
import "forge-std/Test.sol";

contract PriceFeedConsumerTest is Test {
    uint8 public constant DECIMALS = 18;
    int256 public constant INITIAL_ANSWER = 1 * 10**18;
    PriceFeedConsumer public priceFeedConsumer;

    function setUp() public {
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        priceFeedConsumer = new PriceFeedConsumer("BTC", address(mockV3Aggregator));
    }

    function addPriceFeed(string memory _symbol) public {
        MockV3Aggregator mockV3AggregatorETH = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        priceFeedConsumer.addPriceFeed(_symbol, address(mockV3AggregatorETH));
    }

    function testgetLastestPrice() public {
        string memory symbol = "ETH";
        addPriceFeed(symbol);
        int256 price = priceFeedConsumer.getLatestPrice(symbol);
        assertTrue(price == INITIAL_ANSWER);
    }
}