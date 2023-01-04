// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../src/PriceFeedConsumer.sol";
import "./mocks/MockV3Aggregator.sol";
import "forge-std/Test.sol";

contract PriceFeedConsumerTest is Test {
    uint8 public constant DECIMALS = 18;
    int256 public constant INITIAL_ANSWER = 1 * 10 ** 18;
    PriceFeedConsumer public priceFeedConsumer;

    function setUp() public {
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        priceFeedConsumer = new PriceFeedConsumer("BTC", address(mockV3Aggregator));
    }

    // Helpers

    function addPriceFeed(string memory _symbol) public {
        MockV3Aggregator mockV3AggregatorETH = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        priceFeedConsumer.addPriceFeed(_symbol, address(mockV3AggregatorETH));
    }

    // Tests

    function testAddPriceFeeds() public {
        string[4] memory assets = ["ETH", "SOL", "LINK", "XMR"];
        for (uint256 i = 0; i < assets.length; i++) {
            addPriceFeed(assets[i]);
        }
    }

    function testGetLastestPrice() public {
        string memory symbol = "ETH";
        addPriceFeed(symbol);
        int256 price = priceFeedConsumer.getLatestPrice(symbol);
        assertTrue(price == INITIAL_ANSWER);
    }

    function testGetPriceFeed() public {
        string memory symbol = "ETH";
        addPriceFeed(symbol);
        AggregatorV3Interface priceFeed = priceFeedConsumer.getPriceFeed(symbol);
        assertTrue(address(priceFeed) != address(0));
    }

    function testRemovePriceFeed() public {
        string memory symbol = "ETH";
        addPriceFeed(symbol);
        priceFeedConsumer.removePriceFeed(symbol);
        vm.expectRevert("Price feed does not exist.");
        priceFeedConsumer.getPriceFeed(symbol);
    }
}
