// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Portfolio.sol";
import "./mocks/MockV3Aggregator.sol";
import "forge-std/Test.sol";
import "./setup/TestSetup.sol";

contract PortfolioTest is TestSetup {
    // Tests

    function testGetPortfolioValue() public {
        for (uint256 i = 0; i < tokens.length; i++) {
            emit log_address(tokens[i]);
        }
        uint256 value = portfolio.getPortfolioValue();
        //FIXME
        //assertEq(value, portfolioValue, "Portfolio value should be the sum of all assets");
    }

    function testAddAssets() public {
        // i = 1 because WETH has already been added in setUp()
        for (uint256 i = 1; i < tokens.length; i++) {
            addAsset(tokens[i], 2500);
        }
        //FIXME
        //        assertEq(portfolio.getPortfolioValue(), portfolioValue);
    }

    function testRebalance() public {
        // BTC = 100, ETH = 10, SOL = 10, XMR = 10
        uint256 balance = 10;
        // BTC = 25, ETH = 25, SOL = 25, XMR = 25
        uint256 proportion = 25;
        // Initial State - [ BTC = 100% ], PV = 20_000 * 100 = 2_000_000
        addAsset(BTC, 2500);
        addAsset(SOL, 2500);
        addAsset(XMR, 2500);
        portfolioValue = 6_200_000;
        // New State - [ BTC = 25%, ETH = 25%, SOL = 25%, XMR = 25% ]
        // Before Rebalance
        // | Sym | Balance * Price = Value  | Proportion                        |
        // | BTC | 20_000 * 100 = 2_000_000 | 2_000_000 / 6_200_000 = 0.32 = 32 |
        // | ETH | 2_000 * 1000 = 2_000_000 | 2_000_000 / 6_200_000 = 0.32 = 32 |
        // | SOL | 200 * 10000 = 2_000_000  | 2_000_000 / 6_200_000 = 0.32 = 32 |
        // | XMR | 20 * 10000 = 200_000     | 200_000   / 6_200_000 = 0.03 = 3  |
        // | PV  | 2_000_000 + 2_000_000 + 2_000_000 + 200_000 = 6_200_000      |
        //FIXME when we addAsset, there's no associated balance yet.
        //        assertEq(portfolio.getPortfolioValue(), portfolioValue);

        //        portfolio.rebalance(1);
        // After Rebalance
        // | Sym | Previous Value | New Value | Swap   | Change      | New Proportion | Operation |
        // | BTC | 2_000_000      | 1_550_000 | -22    | -440_000    | 0.25 = 25      | Sell      |
        // | ETH | 2_000_000      | 1_550_000 | -225   | -450_000    | 0.25 = 25      | Sell      |
        // | SOL | 2_000_000      | 1_550_000 | -2250  | -450_000    | 0.25 = 25      | Sell      |
        // | XMR | 200_000        | 1_550_000 | 67500  | 1_350_000   | 0.25 = 25      | Buy       |
        // | PV  |

        //        assertEq(portfolio.getPortfolioValue(), portfolioValue);
    }
}
