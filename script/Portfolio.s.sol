// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Script.sol";
import "../src/Portfolio.sol";

contract DeployPortfolio is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        address swapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
        address ethUsdPriceFeed = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
        Portfolio portfolio = new Portfolio(WETH, swapRouter, ethUsdPriceFeed);
        vm.stopBroadcast();
    }
}
