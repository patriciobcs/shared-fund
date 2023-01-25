// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../../src/PriceFeedConsumer.sol";
import "./setup/TestSetup.t.sol";

contract TestPriceFeedConsumerIntegration is TestForkSetup {
    function setUp() public virtual override {
        string memory MAINNET_FORK_RPC_URL = vm.envString("MAINNET_RPC_URL");
        mainnetFork = vm.createFork(MAINNET_FORK_RPC_URL);
        vm.selectFork(mainnetFork);
        priceFeedConsumer = new PriceFeedConsumer(WETH, ethUsdPriceFeed);
    }

    function addConsumer(address _token, address _priceFeed) public {
        priceFeedConsumer.addPriceFeed(_token, _priceFeed);
    }

    function testInitialPrice() public {
        uint256 ethPrice = priceFeedConsumer.getLatestPrice(WETH);
        assertTrue(ethPrice > 1000 * 10 ** CHAINLINK_DECIMALS);
    }

    function testAddConsumer() public {
        addConsumer(AAVE, aaveUsdPriceFeed);
        addConsumer(USDC, usdcUsdPriceFeed);
        assertTrue(priceFeedConsumer.getLatestPrice(AAVE) > 80 * 10 ** CHAINLINK_DECIMALS);
        assertTrue(priceFeedConsumer.getLatestPrice(USDC) >= 1 * 10 ** CHAINLINK_DECIMALS);
    }
}
