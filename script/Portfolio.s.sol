// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Script.sol";
import "../src/Portfolio.sol";

contract PortfolioDeployment is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
        address swapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
        address ethUsdPriceFeed = 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e;
        Portfolio portfolio = new Portfolio(WETH, swapRouter, ethUsdPriceFeed);
        vm.stopBroadcast();
    }
}

contract PorfolioFunding is Script {}
