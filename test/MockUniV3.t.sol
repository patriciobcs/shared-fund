import "./mocks/MockUniV3Router.sol";
import "forge-std/Test.sol";

contract MockUniV3Test is Test {
    MockUniV3Router mockUniV3;

    address USDC;
    address XMR;
    address BTC;
    address SOL;

    function setUp() public {
        mockUniV3 = new MockUniV3Router();
        MockERC20 _sol = new MockERC20("SOL", "SOL");
        MockERC20 _btc = new MockERC20("BTC", "BTC");
        MockERC20 _xmr = new MockERC20("XMR", "XMR");
        MockERC20 _usdc = new MockERC20("USDC", "USDC");

        SOL = address(_sol);
        BTC = address(_btc);
        USDC = address(_usdc);
        XMR = address(_xmr);

        mockUniV3.registerTokenPrice(address(_sol), 200);
        mockUniV3.registerTokenPrice(address(_btc), 20_000);
        mockUniV3.registerTokenPrice(address(_usdc), 1);
    }

    function testRegisterTokenPrices() public {
        uint256 solPrice = mockUniV3.tokenUsdPrice(SOL);
        uint256 btcPrice = mockUniV3.tokenUsdPrice(BTC);
        uint256 usdcPrice = mockUniV3.tokenUsdPrice(USDC);

        assertEq(solPrice, 200);
        assertEq(btcPrice, 20_000);
        assertEq(usdcPrice, 1);

        mockUniV3.registerTokenPrice(address(XMR), 300);
        assertEq(mockUniV3.tokenUsdPrice(XMR), 300);
    }

    /// @dev swap 1 sol for 200 usdc. First we need to allocate ourselves the tokens
    function testExactInputSingle() public {
        MockERC20(SOL).increaseUserBalance(address(this), 1);

        MockUniV3Router.ExactInputSingleParams memory params =
            MockUniV3Router.ExactInputSingleParams(SOL, USDC, 3000, address(this), block.timestamp, 1, 200, 0);
        uint256 amountOut = mockUniV3.exactInputSingle(params);
        assertEq(amountOut, 200);

        uint256 solBalance = MockERC20(SOL).balanceOf(address(this));
        uint256 usdcBalance = MockERC20(USDC).balanceOf(address(this));

        assertEq(solBalance, 0);
        assertEq(usdcBalance, 200);
    }
}
