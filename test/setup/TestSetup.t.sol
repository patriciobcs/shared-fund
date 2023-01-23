// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "../../src/Portfolio.sol";
import "../mocks/MockV3Aggregator.sol";
import "forge-std/Test.sol";
import "aave-v3-core/contracts/protocol/libraries/math/WadRayMath.sol";
import "../mocks/MockUniV3Router.sol";
import "../mocks/MockWETH.sol";
import "../mocks/MockERC20.sol";

contract TestSetup is Test {
    uint256 initialBalance = 0;
    address initialToken;

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

    address SOL;
    address WETH;
    address BTC;
    address XMR;
    address USDC;

    MockUniV3Router mockUniV3;

    /// @dev un-allocated proportion of the portfolio. Meaning that 1-allocatedProportion=remainingProportion
    /// and remainingProportion is the proportion of the portfolio that is not allocated to any asset, meaning that
    /// it's invested in the base currency (WETH)
    uint256 public remainingProportion;

    /// @dev setup the tests in the following state:
    /// 1. WETH is added to the portfolio as the base currency - We need to deploy a mock WETH contract
    /// 2. Create a mock aggregator for WETH setting the price to 2,000 USD
    /// 3. Create a mock UNIV3 contract for swaps
    /// 4. Create mock aggregators for BTC,SOL,XMR mock tokens
    /// 5. Invite users to the portfolio
    /// 6. Register the prices of the MockERC20 in the MockUniV3 contract
    /// This setup is used in all tests unless specifically override.
    function setUp() public virtual {
        MockWETH9 _weth9 = new MockWETH9();
        MockERC20 _sol = new MockERC20("SOL", "SOL");
        MockERC20 _btc = new MockERC20("BTC", "BTC");
        MockERC20 _xmr = new MockERC20("XMR", "XMR");
        MockERC20 _usdc = new MockERC20("USDC", "USDC");

        WETH = address(_weth9);
        SOL = address(_sol);
        BTC = address(_btc);
        XMR = address(_xmr);
        USDC = address(_usdc);

        mockUniV3 = new MockUniV3Router();

        setAsset(WETH, 9, 2_000);
        setAsset(BTC, 6, 20_000);
        setAsset(SOL, 9, 200);
        setAsset(XMR, 9, 20);
        setAsset(USDC, 6, 1);

        initialToken = WETH;
        portfolio = new Portfolio(WETH, address(mockUniV3), address(assets[initialToken].aggregator));
        assets[initialToken].proportion = 10_000;
        remainingProportion = 10_000;

        inviteUsers();
    }

    function addAsset(address _token, uint256 _proportion) public {
        portfolio.addAsset(_token, _proportion, address(assets[_token].aggregator));
        assets[_token].proportion = _proportion;
    }

    function setAsset(address _token, uint8 _decimals, uint256 _price) public {
        MockV3Aggregator mockV3AggregatorETH = new MockV3Aggregator(_decimals, int(_price));
        mockUniV3.registerTokenPrice(_token, _price);
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
