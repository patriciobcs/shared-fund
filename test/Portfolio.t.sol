// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../src/Portfolio.sol";
import "./mocks/MockV3Aggregator.sol";
import "forge-std/Test.sol";

contract PortfolioTest is Test {
    uint8 public constant DECIMALS = 18;
    int256 public constant INITIAL_ANSWER = 1 * 10**18;
    uint256 balance = 100;
    Portfolio public portfolio;

    function setUp() public {
        MockV3Aggregator mockV3AggregatorETH = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        portfolio = new Portfolio("BTC", balance, address(mockV3AggregatorETH));
    }

    // Helpers

    function addAsset(string memory _symbol, uint256 _balance) public {
        MockV3Aggregator mockV3AggregatorETH = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        portfolio.addAsset(_symbol, _balance,  address(mockV3AggregatorETH));
    }

    // Tests

    function testAddAssets() public {
        string[4] memory assets = ["ETH", "SOL", "LINK", "XMR"];
        uint256 initialBalance = 100;
        for (uint256 i = 0; i < assets.length; i++) {
           addAsset(assets[i], initialBalance);
           balance += initialBalance;
        }
        assertEq(portfolio.getPortfolioValue(), balance * uint(INITIAL_ANSWER));
    }

    function testChangeAssetBalance() public {
        string memory symbol = "ETH";
        uint256 assetBalance = 100;
        addAsset(symbol, assetBalance);

        uint256 addition = 200;
        portfolio.changeAssetBalance(symbol, addition, true);
        assetBalance += addition;
        assertEq(portfolio.getAssetValue(symbol), assetBalance * uint(INITIAL_ANSWER));

        uint256 subtraction = 50;
        portfolio.changeAssetBalance(symbol, subtraction, false);
        assetBalance -= subtraction;
        assertEq(portfolio.getAssetValue(symbol), assetBalance * uint(INITIAL_ANSWER));

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