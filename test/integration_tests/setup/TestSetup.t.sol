// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "../../../src/Portfolio.sol";
import "forge-std/Test.sol";
import "aave-v3-core/contracts/protocol/libraries/math/WadRayMath.sol";

contract TestForkSetup is Test {
    uint256 initialBalance = 0;
    address initialToken;

    struct Asset {
        uint8 decimals;
        uint256 proportion;
        address aggregator;
    }

    mapping(address => Asset) public assets;
    address[] public tokens;
    uint256 portfolioValue;
    Portfolio public portfolio;
    uint256 WAD = WadRayMath.WAD;
    uint256 PERCENTAGE_FACTOR = PercentageMath.PERCENTAGE_FACTOR;

    address user1 = address(0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF);
    address user2 = address(0x8cedE0C4fA841021E2771ebC6A4c308be26919Fa);
    address user3 = address(0x4960E61111Ce831BCd39b160F94c6921A71E6F58);
    address swapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address ethUsdPriceFeed = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address btcUsdPriceFeed = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c;
    address LINK = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address linkUsdPriceFeed = 0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c;
    address AAVE = 0x6Df09E975c830ECae5bd4eD9d90f3A95a4f88012;
    address aaveUsdPriceFeed = 0x6Df09E975c830ECae5bd4eD9d90f3A95a4f88012;
    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address usdcUsdPriceFeed = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;

    /// @dev un-allocated proportion of the portfolio. Meaning that 1-allocatedProportion=remainingProportion
    /// and remainingProportion is the proportion of the portfolio that is not allocated to any asset, meaning that
    /// it's invested in the base currency (WETH)
    uint256 public remainingProportion;
    uint256 mainnetFork;

    uint256 ethPrice;
    uint256 usdcPrice;

    uint8 CHAINLINK_DECIMALS = 8;

    PriceFeedConsumer priceFeedConsumer;

    /// @dev setup the tests in the following state:
    /// 1. WETH is added to the portfolio as the base currency - We need to deploy a mock WETH contract
    /// 2. Create a mock aggregator for WETH setting the price to 2,000 USD
    /// 3. Create a mock UNIV3 contract for swaps
    /// 4. Create mock aggregators for BTC,SOL,XMR mock tokens
    /// 5. Invite users to the portfolio
    /// 6. Register the prices of the MockERC20 in the MockUniV3 contract
    /// This setup is used in all tests unless specifically override.
    function setUp() public virtual {
        string memory MAINNET_FORK_RPC_URL = vm.envString("MAINNET_RPC_URL");
        mainnetFork = vm.createFork(MAINNET_FORK_RPC_URL);
        vm.selectFork(mainnetFork);
        priceFeedConsumer = new PriceFeedConsumer(WETH, ethUsdPriceFeed);

        assets[WETH] = Asset(18, 0, ethUsdPriceFeed);
        tokens.push(WETH);

        setAsset(LINK, 18, linkUsdPriceFeed);
        setAsset(WBTC, 18, btcUsdPriceFeed);
        setAsset(AAVE, 18, aaveUsdPriceFeed);
        setAsset(USDC, 6, usdcUsdPriceFeed);

        portfolio = new Portfolio(WETH, swapRouter, address(ethUsdPriceFeed));
        assets[initialToken].proportion = 10_000;
        remainingProportion = 10_000;

        inviteUsers();
        setPrices();
    }

    function addAsset(address _token, uint256 _proportion) public {
        portfolio.addAsset(_token, _proportion, address(assets[_token].aggregator));
        assets[_token].proportion = _proportion;
    }

    function setAsset(address _token, uint8 _decimals, address priceFeed) public {
        assets[_token] = Asset(_decimals, 0, priceFeed);
        priceFeedConsumer.addPriceFeed(_token, priceFeed);
        tokens.push(_token);
    }

    function setPrices() internal {
        ethPrice = priceFeedConsumer.getLatestPrice(WETH);
        usdcPrice = priceFeedConsumer.getLatestPrice(USDC);
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
