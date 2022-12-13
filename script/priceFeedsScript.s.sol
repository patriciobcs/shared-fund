// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "forge-std/Script.sol";
import {PriceConsumerV3} from "src/priceFeeds.sol";
contract ChainlinkScript is Script {
    function setUp() public {}
    function run() public {
        vm.startBroadcast();
        PriceConsumerV3 prices = new PriceConsumerV3();
        vm.stopBroadcast();
    }
}