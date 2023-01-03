// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../src/Portfolio.sol";
import "./mocks/MockV3Aggregator.sol";
import "forge-std/Test.sol";

contract PortfolioTest is Test {
    struct Asset {
        uint8 decimals;
        uint256 price;
        uint256 balance;
        uint256 proportion;
        bool isFlexible;
        MockV3Aggregator aggregator;
    }
    mapping(string => Asset) public assets;
    string[] public symbols;
    uint256 portfolioValue;
    Portfolio public portfolio;
    string initialSymbol = "BTC";
    uint256 initialBalance = 100;

    function setUp() public {
        setAsset("BTC", 6, 20_000);
        setAsset("ETH", 9, 2_000);
        setAsset("SOL", 9, 200);
        setAsset("XMR", 9, 20);

        portfolio = new Portfolio(initialSymbol, initialBalance, true, address(assets[initialSymbol].aggregator));
        assets[initialSymbol].balance = initialBalance;
        assets[initialSymbol].proportion = 100;
        portfolioValue = initialBalance * assets[initialSymbol].price;
    }

    // Helpers

    function setAsset(string memory _symbol, uint8 _decimals, uint256 _price) public {
        MockV3Aggregator mockV3AggregatorETH = new MockV3Aggregator(_decimals, int(_price));
        assets[_symbol] = Asset(_decimals, _price, 0, 0, true, mockV3AggregatorETH);
        symbols.push(_symbol);
    }

    function addAsset(string memory _symbol, uint256 _balance, uint256 _proportion, bool _isFlexible) public {
        portfolio.addAsset(_symbol, _balance, _proportion, _isFlexible, address(assets[_symbol].aggregator));
        assets[_symbol].balance = _balance;
        assets[_symbol].proportion = _proportion;
        assets[_symbol].isFlexible = _isFlexible;
    }

    // Tests

    function testAddAssets() public {
        for (uint256 i = 1; i < symbols.length; i++) {
           addAsset(symbols[i], (i + 1) * initialBalance, 25, false);
           portfolioValue += (i + 1) * initialBalance * assets[symbols[i]].price;
        }
        assertEq(portfolio.getPortfolioValue(), portfolioValue);
    }

    function testChangeAssetBalance() public {
        string memory symbol = "ETH";
        uint256 assetBalance = 100;
        addAsset(symbol, assetBalance, 25, false);
        assets[initialSymbol].proportion = 75;
        assertEq(portfolio.getAssetValue(symbol), assetBalance * assets[symbol].price);
        assertEq(portfolio.getAssetProportion(symbol), 25);
        assertEq(portfolio.getAssetProportion(initialSymbol), assets[initialSymbol].proportion);

        uint256 addition = 200;
        portfolio.changeAssetBalance(symbol, addition, true);
        assetBalance += addition;
        assertEq(portfolio.getAssetValue(symbol), assetBalance * assets[symbol].price);

        uint256 subtraction = 50;
        portfolio.changeAssetBalance(symbol, subtraction, false);
        assetBalance -= subtraction;
        assertEq(portfolio.getAssetValue(symbol), assetBalance * assets[symbol].price);

        uint256 deletion = 10000000;
        portfolio.changeAssetBalance(symbol, deletion, false);
        vm.expectRevert("Asset does not exist in the portfolio.");
        portfolio.getAssetValue(symbol);
    }

    function testIncorrectOwner() public {
        string memory symbol = "ETH";
        uint256 assetBalance = 100;
        addAsset(symbol, assetBalance, 25, false);

        vm.startPrank(address(0x1));
        vm.expectRevert("Ownable: caller is not the owner");
        portfolio.changeAssetBalance("ETH", 100, true);
        vm.stopPrank();
    }

    function testAddConstantProportions() public {
        string memory ethSymbol = "ETH";
        uint256 ethBalance = 100;
        uint256 ethProportion = 25;

        addAsset(ethSymbol, ethBalance, ethProportion, false);
        assets[initialSymbol].proportion -= ethProportion;

        assertEq(portfolio.getAssetProportion(ethSymbol), ethProportion);
        assertEq(portfolio.getAssetProportion(initialSymbol), assets[initialSymbol].proportion);

        string memory solSymbol = "SOL";
        uint256 solBalance = 100;
        uint256 solProportion = 50;

        addAsset(solSymbol, solBalance, solProportion, false);
        assets[initialSymbol].proportion -= solProportion;

        assertEq(portfolio.getAssetProportion(ethSymbol), ethProportion);
        assertEq(portfolio.getAssetProportion(initialSymbol), assets[initialSymbol].proportion);
        assertEq(portfolio.getAssetProportion(solSymbol), solProportion);
    }

    function testRejectConstantProportionHigherThanAvailable() public {
        string memory ethSymbol = "ETH";
        uint256 ethBalance = 100;
        uint256 ethProportion = 75;

        addAsset(ethSymbol, ethBalance, ethProportion, false);
        assets[initialSymbol].proportion -= ethProportion;

        assertEq(portfolio.getAssetProportion(ethSymbol), ethProportion);
        assertEq(portfolio.getAssetProportion(initialSymbol), assets[initialSymbol].proportion);

        string memory solSymbol = "SOL";
        uint256 solBalance = 100;
        uint256 solProportion = 50;

        vm.expectRevert("Not sufficient proportion available.");
        addAsset(solSymbol, solBalance, solProportion, false);
    }

    function testTwoFlexibleProportionsAndOneConstantProportion() public {
        uint256 flexibleProportion = 100;
        string memory ethSymbol = "ETH";
        uint256 ethBalance = 100;
        uint256 ethProportion = 50;

        addAsset(ethSymbol, ethBalance, ethProportion, true);
        assets[initialSymbol].proportion -= ethProportion;

        assertEq(portfolio.getAssetProportion(ethSymbol), ethProportion);
        assertEq(portfolio.getAssetProportion(initialSymbol), assets[initialSymbol].proportion);

        string memory solSymbol = "SOL";
        uint256 solBalance = 100;
        uint256 solProportion = 50;

        addAsset(solSymbol, solBalance, solProportion, false);
        flexibleProportion -= solProportion;
        assets[ethSymbol].proportion = assets[ethSymbol].proportion * flexibleProportion / 100;
        assets[initialSymbol].proportion = assets[initialSymbol].proportion * flexibleProportion / 100;

        assertEq(portfolio.getAssetProportion(ethSymbol), assets[ethSymbol].proportion);
        assertEq(portfolio.getAssetProportion(initialSymbol), assets[initialSymbol].proportion);
        assertEq(portfolio.getAssetProportion(solSymbol), solProportion);
    }

    function testRebalance() public {
        // BTC = 100, ETH = 10, SOL = 10, XMR = 10
        uint256 balance = 10;
        // BTC = 25, ETH = 25, SOL = 25, XMR = 25
        uint256 proportion = 25;
        // Initial State - [ BTC = 100% ], PV = 20_000 * 100 = 2_000_000
        addAsset("ETH", 1_000, 25, false);
        addAsset("SOL", 10_000, 25, false);
        addAsset("XMR", 10_000, 25, false);
        portfolioValue = 6_200_000; 
        // New State - [ BTC = 25%, ETH = 25%, SOL = 25%, XMR = 25% ]
        // Before Rebalance
        // | Sym | Balance * Price = Value  | Proportion                        | 
        // | BTC | 20_000 * 100 = 2_000_000 | 2_000_000 / 6_200_000 = 0.32 = 32 |
        // | ETH | 2_000 * 1000 = 2_000_000 | 2_000_000 / 6_200_000 = 0.32 = 32 |
        // | SOL | 200 * 10000 = 2_000_000  | 2_000_000 / 6_200_000 = 0.32 = 32 |
        // | XMR | 20 * 10000 = 200_000     | 200_000   / 6_200_000 = 0.03 = 3  |
        // | PV  | 2_000_000 + 2_000_000 + 2_000_000 + 200_000 = 6_200_000      |
        assertEq(portfolio.getPortfolioValue(), portfolioValue);
        
        portfolio.rebalance(1);
        // After Rebalance
        // | Sym | Previous Value | New Value | Swap   | Change      | New Proportion | Operation |
        // | BTC | 2_000_000      | 1_550_000 | -22    | -440_000    | 0.25 = 25      | Sell      |
        // | ETH | 2_000_000      | 1_550_000 | -225   | -450_000    | 0.25 = 25      | Sell      |
        // | SOL | 2_000_000      | 1_550_000 | -2250  | -450_000    | 0.25 = 25      | Sell      |
        // | XMR | 200_000        | 1_550_000 | 67500  | 1_350_000   | 0.25 = 25      | Buy       |
        // | PV  | 

        assertEq(portfolio.getPortfolioValue(), portfolioValue);
    }
}