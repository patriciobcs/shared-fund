// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "../../src/PriceFeedConsumer.sol";
import "../mocks/MockV3Aggregator.sol";
import "forge-std/Test.sol";

contract PriceFeedConsumerTest is Test {
    uint8 public constant DECIMALS = 18;
    int256 public constant INITIAL_ANSWER = 1 * 10 ** 18;
    PriceFeedConsumer public priceFeedConsumer;
    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address BTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address LINK = 0x514910771AF9Ca656af840dff83E8264EcF986CA;

    function setUp() public {
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        priceFeedConsumer = new PriceFeedConsumer(BTC, address(mockV3Aggregator));
    }

    // Helpers

    function addPriceFeed(address _token) public {
        MockV3Aggregator mockV3AggregatorETH = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        priceFeedConsumer.addPriceFeed(_token, address(mockV3AggregatorETH));
    }

    // Tests

    function testAddPriceFeeds() public {
        address[3] memory assets = [USDC, WETH, LINK];
        for (uint256 i = 0; i < assets.length; i++) {
            addPriceFeed(assets[i]);
        }
    }

    function testGetLastestPrice() public {
        addPriceFeed(WETH);
        uint256 price = priceFeedConsumer.getLatestPrice(WETH);
        assertTrue(price == uint256(INITIAL_ANSWER * 1e8));
    }

    function testGetPriceFeed() public {
        addPriceFeed(WETH);
        AggregatorV3Interface priceFeed = priceFeedConsumer.getPriceFeed(WETH);
        assertTrue(address(priceFeed) != address(0));
    }

    function testRemovePriceFeed() public {
        addPriceFeed(WETH);
        priceFeedConsumer.removePriceFeed(WETH);
        vm.expectRevert("Price feed does not exist.");
        priceFeedConsumer.getPriceFeed(WETH);
    }
}
