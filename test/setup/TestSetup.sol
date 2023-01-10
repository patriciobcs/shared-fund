// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../src/Portfolio.sol";
import "../mocks/MockV3Aggregator.sol";
import "forge-std/Test.sol";

contract TestSetup is Test {
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
    uint256 WAD = WadRayMath.WAD;
    uint256 PERCENTAGE_FACTOR = PercentageMath.PERCENTAGE_FACTOR;

    address user1 = address(0x123);
    address user2 = address(0x456);
    address user3 = address(0x789);

    // Contract creation with
    function setUp() public virtual {
        setAsset("ETH", 9, 2_000);
        Asset memory eth = assets["ETH"];
        portfolio = new Portfolio("ETH", eth.balance, true, address(eth.aggregator));
        inviteUsers();
    }

    function setAsset(string memory _symbol, uint8 _decimals, uint256 _price) public {
        MockV3Aggregator mockV3AggregatorETH = new MockV3Aggregator(_decimals, int(_price));
        assets[_symbol] = Asset(_decimals, _price, 0, 0, true, mockV3AggregatorETH);
        symbols.push(_symbol);
    }

    function inviteUsers() internal {
        portfolio.invite(user1);
        portfolio.invite(user2);
        portfolio.invite(user3);
    }

    function deposit(address user, uint256 tokenId, uint256 amount) public {
        vm.startPrank(user);
        vm.deal(user, amount);
        portfolio.deposit{value: amount}(tokenId);
        vm.stopPrank();
    }
}
