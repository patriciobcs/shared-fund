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

    // @dev Tests a portfolio with 50% ETH and 50% USDC.
    //      Given a price of ETH of approximatively 1500$ and a price of USDC of approximatively 1$,
    //      the portfolio should have 1/2 * 1600 / 1 = 800 USDC.
    function testFiftyEthFiftyUSDC() public {
        deposit(user1, 1, 1 ether);
        portfolio.addAsset(USDC, 5_000, address(assets[USDC].aggregator));
        uint256 usdcBalance = IERC20(USDC).balanceOf(address(portfolio));
        assertEq(usdcBalance, 0);
        portfolio.rebalance();
        usdcBalance = IERC20(USDC).balanceOf(address(portfolio));
        uint256 usdcDecimals = IERC20Metadata(USDC).decimals();
        // we swapped 1 ether for (0.5 ethPrice/usdcPrice) usdc
        uint256 expectedUsdcBalance =
            (1 * uint256(ethPrice) / uint256(usdcPrice)) * (10 ** usdcDecimals) * 5000 / PERCENTAGE_FACTOR;
        assertGe(usdcBalance, expectedUsdcBalance * 9 / 10);
        assertLe(usdcBalance, expectedUsdcBalance * 11 / 10);
    }
}
