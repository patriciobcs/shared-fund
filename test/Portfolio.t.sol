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
        MockV3Aggregator aggregator;
    }
    mapping(string => Asset) public assets;
    string[] public symbols;
    uint256 portfolioValue;
    Portfolio public portfolio;

    function setUp() public {
        setAsset("BTC", 6, 20_000);
        setAsset("ETH", 9, 2_000);
        setAsset("XMR", 9, 200);
        setAsset("SOL", 9, 20);

        uint256 initialBalance = 100;
        string memory initialAsset = "BTC";
        portfolio = new Portfolio(initialAsset, initialBalance, address(assets[initialAsset].aggregator));
        assets[initialAsset].balance = initialBalance;
        portfolioValue = initialBalance * assets[initialAsset].price;
        symbols.push(initialAsset);
    }

    // Helpers

    function setAsset(string memory _symbol, uint8 _decimals, uint256 _price) public {
        MockV3Aggregator mockV3AggregatorETH = new MockV3Aggregator(_decimals, int(_price));
        assets[_symbol] = Asset(_decimals, _price, 0, mockV3AggregatorETH);
    }

    function addAsset(string memory _symbol, uint256 _balance) public {
        portfolio.addAsset(_symbol, _balance, address(assets[_symbol].aggregator));
        assets[_symbol].balance = _balance;
        symbols.push(_symbol);
    }

    // Tests

    function testAddAssets() public {
        uint256 initialBalance = 100;
        for (uint256 i = 1; i < symbols.length; i++) {
           addAsset(symbols[i], (i + 1) * initialBalance);
           portfolioValue += initialBalance * assets[symbols[i]].price;
        }
        assertEq(portfolio.getPortfolioValue(), portfolioValue);
    }

    function testChangeAssetBalance() public {
        string memory symbol = "ETH";
        uint256 assetBalance = 100;
        addAsset(symbol, assetBalance);

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
        addAsset(symbol, assetBalance);

        vm.startPrank(address(0x1));
        vm.expectRevert("Only the owner of the portfolio can call this function.");
        portfolio.changeAssetBalance("ETH", 100, true);
        vm.stopPrank();
    }
}