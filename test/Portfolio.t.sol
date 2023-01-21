// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Portfolio.sol";
import "./mocks/MockV3Aggregator.sol";
import "forge-std/Test.sol";
import "./setup/TestSetup.sol";

contract PortfolioTest is TestSetup {
    uint256 initialBalance = 0;
    address initialToken;

    function setUp() public override {
        MockWETH9 WETH = new MockWETH9();
        setAsset(address(WETH), 9, 2_000);
        Asset memory weth = assets[address(WETH)];
        initialToken = address(WETH);
        MockUniV3 uniV3 = new MockUniV3();
        setAsset(BTC, 6, 20_000);
        setAsset(SOL, 9, 200);
        setAsset(XMR, 9, 20);
        emit log_address(address(WETH));

        portfolio = new Portfolio(address(WETH), address(uniV3), address(assets[initialToken].aggregator));
        assets[initialToken].proportion = 10_000;
        // on setup, no ETH has been deposited so portfolio value is 0
        portfolioValue = 0;
        remainingProportion = 10_000;
    }

    function addAsset(address _token, uint256 _proportion) public {
        portfolio.addAsset(_token, _proportion, address(assets[_token].aggregator));
        assets[_token].proportion = _proportion;
    }

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

    function testIncorrectOwner() public {
        address token = USDC;
        uint256 assetBalance = 100;
        addAsset(token, 2500);

        vm.startPrank(address(0x1));
        vm.expectRevert("Ownable: caller is not the owner");
        portfolio.changeAssetProportion(token, 5000);
        vm.stopPrank();
    }

    function testAddConstantProportions() public {
        address tokenA = BTC;
        uint256 tokenABalance = 100;
        uint256 tokenAProportion = 2_500;

        addAsset(tokenA, tokenAProportion);
        remainingProportion -= tokenAProportion;

        assertEq(portfolio.getAssetProportion(tokenA), tokenAProportion);
        assertEq(portfolio.getRemainingProportion(), remainingProportion);

        address solToken = SOL;
        uint256 solBalance = 100;
        uint256 solProportion = 5_000;

        addAsset(solToken, solProportion);
        remainingProportion -= solProportion;

        assertEq(portfolio.getAssetProportion(tokenA), tokenAProportion);
        assertEq(portfolio.getRemainingProportion(), remainingProportion);
        assertEq(portfolio.getAssetProportion(solToken), solProportion);
    }

    function testRejectConstantProportionHigherThanAvailable() public {
        address tokenA = BTC;
        uint256 tokenABalance = 100;
        uint256 tokenAProportion = 7_500;

        addAsset(tokenA, tokenAProportion);
        remainingProportion -= tokenAProportion;

        assertEq(portfolio.getAssetProportion(tokenA), tokenAProportion);
        assertEq(portfolio.getRemainingProportion(), remainingProportion);

        address solToken = SOL;
        uint256 solBalance = 100;
        uint256 solProportion = 5_000;

        vm.expectRevert("REMAINING_PROPORTION_TOO_LOW");
        addAsset(solToken, solProportion);
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
