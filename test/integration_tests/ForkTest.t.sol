// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../../src/Portfolio.sol";
import "./setup/TestSetup.t.sol";

contract ForkTest is TestForkSetup {
    // the identifiers of the forks

    function testActiveFork() public {
        // select the fork
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);
    }

    //TODO
    function testFiftyEthFiftyUSDC() public {
        deposit(user1, 1, 1 ether);
        portfolio.addAsset(USDC, 5_000, address(assets[USDC].aggregator));
        uint256 usdcBalance = IERC20(USDC).balanceOf(address(portfolio));
        assertEq(usdcBalance, 0);
        portfolio.rebalance(1);
        usdcBalance = IERC20(USDC).balanceOf(address(portfolio));
        // we swapped 1 ether for ethPrice/usdcPrice usdc
        uint256 expectedUsdcBalance = (1 * uint256(ethPrice) / uint256(usdcPrice));
        assertGe(usdcBalance, expectedUsdcBalance * 9 / 10);
        assertLe(usdcBalance, expectedUsdcBalance * 11 / 10);
    }
}
