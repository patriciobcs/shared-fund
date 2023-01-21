// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../src/Portfolio.sol";
import "../mocks/MockV3Aggregator.sol";
import "forge-std/Test.sol";
import "aave-v3-core/contracts/protocol/libraries/math/WadRayMath.sol";
import "../mocks/MockUniV3.sol";
import "../mocks/MockWETH.sol";

contract TestSetup is Test {
    struct Asset {
        uint8 decimals;
        uint256 price;
        uint256 balance;
        uint256 proportion;
        bool isFlexible;
        MockV3Aggregator aggregator;
    }

    mapping(address => Asset) public assets;
    address[] public tokens;
    uint256 portfolioValue;
    Portfolio public portfolio;
    uint256 WAD = WadRayMath.WAD;
    uint256 PERCENTAGE_FACTOR = PercentageMath.PERCENTAGE_FACTOR;

    address user1 = address(0x123);
    address user2 = address(0x456);
    address user3 = address(0x789);

    address SOL = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address WETH;
    address BTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address XMR = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address USDC = 0x2f3A40A3db8a7e3D09B0adfEfbCe4f6F81927557;

    /// @dev un-allocated proportion of the portfolio. Meaning that 1-allocatedProportion=remainingProportion
    /// and remainingProportion is the proportion of the portfolio that is not allocated to any asset, meaning that
    /// it's invested in the base currency (WETH)
    uint256 public remainingProportion;

    // Contract creation with
    function setUp() public virtual {
        MockWETH9 _weth = new MockWETH9();
        WETH = address(_weth);

        setAsset(address(WETH), 9, 2_000);
        Asset memory weth = assets[address(WETH)];

        MockUniV3 uniV3 = new MockUniV3();
        portfolio = new Portfolio(address(WETH), address(uniV3), address(weth.aggregator));

        remainingProportion = 10_000;
        inviteUsers();
    }

    function setAsset(address _token, uint8 _decimals, uint256 _price) public {
        MockV3Aggregator mockV3AggregatorETH = new MockV3Aggregator(_decimals, int(_price));
        assets[_token] = Asset(_decimals, _price, 0, 0, true, mockV3AggregatorETH);
        tokens.push(_token);
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
