// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "../src/Portfolio.sol";
import "./mocks/MockV3Aggregator.sol";
import "forge-std/Test.sol";
import "./setup/TestSetup.t.sol";

contract PortfolioTest is TestSetup {
    // Tests

    /// @dev initially our portfolio is 100% WETH with a balance of 0.
    function testGetPortfolioValueOnlyEther() public {
        uint256 wethBalance = IERC20(WETH).balanceOf(address(portfolio));
        assertEq(wethBalance, 0);
        uint256 portfolioValue = portfolio.getPortfolioValue();
        assertTrue(portfolioValue == 0);

        deposit(user1, 1, 1 ether);
        wethBalance = IERC20(WETH).balanceOf(address(portfolio));
        assertEq(wethBalance, 1 ether);
        portfolioValue = portfolio.getPortfolioValue();
        assertTrue(portfolioValue == 2000 * PRICEFEED_PRECISION);
    }

    /// @dev initially our portfolio is 100% WETH with a balance of 1 ether.
    ///     The expected value is 2000$.
    ///     We then rebalance for 50% WETH, 25% USDC and 25% BTC.
    ///     The expected value is 2000$ with USDC and BTC prices fixed at 1$ and 20,000$.
    function testGetPortfolioValueMultipleTokens() public {
        deposit(user1, 1, 1 ether);
        uint256 value = portfolio.getPortfolioValue();
        assertEq(value, 2_000 * PRICEFEED_PRECISION, "Portfolio value should be the sum of all assets");
        portfolio.addAsset(USDC, 2_500, address(assets[USDC].aggregator));
        portfolio.addAsset(BTC, 2_500, address(assets[BTC].aggregator));
        portfolio.rebalance();
        value = portfolio.getPortfolioValue();
        assertEq(value, 2_000 * PRICEFEED_PRECISION, "Portfolio value should be the sum of all assets");
    }

    // @dev Tests rebalance function with only one asset to buy.
    //      The price of ether is fixed at 2,000 USD. The price of USDC is fixed at 1 USD.
    //      The portfolio is 100% WETH with a balance of 1 ether before rebalancing to 75% WETH and 25% USDC.
    //      Thus, we expect to buy 0.25 ether worth of USDC, which is 500 USDC
    //      USDC is considered to be an 18-decimal token here.
    function testRebalanceBuyOneToken() public {
        deposit(user1, 1, 1 ether);
        portfolio.addAsset(USDC, 2_500, address(assets[USDC].aggregator));
        portfolio.rebalance();
        uint256 usdcBalance = IERC20(USDC).balanceOf(address(portfolio));
        assertEq(usdcBalance, 500 * ERC20_PRECISION);
        uint256 wethBalance = IERC20(WETH).balanceOf(address(portfolio));
        assertEq(wethBalance, 0.75 ether);
    }

    // @dev Tests rebalance function with only one asset to buy.
    //      The price of ether is fixed at 2,000 USD. The price of USDC is fixed at 1 USD.
    //      The price of BTC is fixed at 20,000 USD.
    //      The portfolio is 100% WETH with a balance of 1 ether before rebalancing to 75% WETH and 25% USDC.
    //      Thus, we expect to buy 0.25 ether worth of USDC, which is 500 USDC
    //      And 0.25 ether worth of BTC, which is 0.025 btc
    function testRebalanceBuyTwoTokens() public {
        deposit(user1, 1, 1 ether);
        portfolio.addAsset(USDC, 2_500, address(assets[USDC].aggregator));
        portfolio.addAsset(BTC, 2_500, address(assets[BTC].aggregator));
        portfolio.rebalance();
        uint256 usdcBalance = IERC20(USDC).balanceOf(address(portfolio));
        assertEq(usdcBalance, 500 * ERC20_PRECISION);
        uint256 btcBalance = IERC20(BTC).balanceOf(address(portfolio));
        assertEq(btcBalance, 25 * (ERC20_PRECISION / 1000));
        uint256 wethBalance = IERC20(WETH).balanceOf(address(portfolio));
        assertEq(wethBalance, 0.5 ether);
    }

    // @dev Tests rebalance function with only one asset to sell.
    //      The price of ether is fixed at 2,000 USD. The price of USDC is fixed at 1 USD.
    //      The portfolio is 50% WETH 50% USDC and we rebalance to 100% WETH.
    //      Thus, we expect to sell 0.5 ether worth of USDC, which is 1,000 USDC
    function testRebalanceSellOneToken() public {
        // setup
        deposit(user1, 1, 1 ether);
        portfolio.addAsset(USDC, 5_000, address(assets[USDC].aggregator));
        portfolio.rebalance();
        uint256 usdcBalance = IERC20(USDC).balanceOf(address(portfolio));
        assertEq(usdcBalance, 1_000 * 10 ** 18);

        // test
        portfolio.changeAssetProportion(USDC, 0);
        portfolio.rebalance();
        usdcBalance = IERC20(USDC).balanceOf(address(portfolio));
        assertEq(usdcBalance, 0);
        uint256 wethBalance = IERC20(WETH).balanceOf(address(portfolio));
        assertEq(wethBalance, 1 ether);
    }

    // @dev Tests rebalance function with only one asset to sell.
    //      The price of ether is fixed at 2,000 USD. The price of USDC is fixed at 1 USD.
    //      The portfolio is 50% WETH 25% USDC 25% BTC and we rebalance to 100% WETH.
    //      Thus, we expect to sell 0.5 ether worth of USDC, which is 1,000 USDC
    //      And 0.5 ether worth of BTC, which is 0.05 btc
    function testRebalanceSellTwoTokens() public {
        // setup
        deposit(user1, 1, 1 ether);
        portfolio.addAsset(USDC, 2_500, address(assets[USDC].aggregator));
        portfolio.addAsset(BTC, 2_500, address(assets[BTC].aggregator));
        portfolio.rebalance();

        // test
        portfolio.changeAssetProportion(USDC, 0);
        portfolio.changeAssetProportion(BTC, 0);
        portfolio.rebalance();
        uint256 usdcBalance = IERC20(USDC).balanceOf(address(portfolio));
        assertEq(usdcBalance, 0);
        uint256 btcBalance = IERC20(BTC).balanceOf(address(portfolio));
        assertEq(btcBalance, 0);
        uint256 wethBalance = IERC20(WETH).balanceOf(address(portfolio));
        assertEq(wethBalance, 1 ether);
    }

    // @dev Tests rebalance function with one asset to sell and one asset to buy.
    //      The price of ether is fixed at 2,000 USD. The price of USDC is fixed at 1 USD.
    //      The price of BTC is fixed at 20,000 USD.
    //      The portfolio is 100% USDC and we rebalance to 50% WETH 25% BTC 25% USDC.
    //      Thus, we expect to sell 0.75 ether worth of USDC , which is 1,500 USDC
    //      And buy 0.25 ether worth of BTC, which is 0.025 btc
    function testRebalanceSellOneBuyOne() public {
        // setup
        deposit(user1, 1, 1 ether);
        portfolio.addAsset(USDC, 10_000, address(assets[USDC].aggregator));
        portfolio.rebalance();
        uint256 usdcBalance = IERC20(USDC).balanceOf(address(portfolio));
        assertEq(usdcBalance, 2_000 * ERC20_PRECISION);

        // test
        portfolio.changeAssetProportion(USDC, 2_500);
        portfolio.addAsset(BTC, 2_500, address(assets[BTC].aggregator));
        portfolio.rebalance();
        usdcBalance = IERC20(USDC).balanceOf(address(portfolio));
        assertEq(usdcBalance, 500 * ERC20_PRECISION);
        uint256 btcBalance = IERC20(BTC).balanceOf(address(portfolio));
        assertEq(btcBalance, 25 * 10 ** 15);
        uint256 wethBalance = IERC20(WETH).balanceOf(address(portfolio));
        assertEq(wethBalance, 0.5 ether);
    }
}
