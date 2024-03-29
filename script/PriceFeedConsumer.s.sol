// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Script.sol";
import "../src/PriceFeedConsumer.sol";
import "./HelperConfig.sol";
import "../test/mocks/MockV3Aggregator.sol";

contract DeployPriceFeedConsumer is Script, HelperConfig {
    uint8 constant DECIMALS = 18;
    int256 constant INITIAL_ANSWER = 2000e18;
    address BTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    function run() external {
        HelperConfig helperConfig = new HelperConfig();

        (,,,,, address priceFeed,,,) = helperConfig.activeNetworkConfig();

        if (priceFeed == address(0)) {
            priceFeed = address(new MockV3Aggregator(DECIMALS, INITIAL_ANSWER));
        }

        vm.startBroadcast();

        new PriceFeedConsumer(BTC, priceFeed);

        vm.stopBroadcast();
    }
}
