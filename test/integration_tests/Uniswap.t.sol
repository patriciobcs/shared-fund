// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../../src/PriceFeedConsumer.sol";
import "../../src/interfaces/external/IWETH9.sol";
import "uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "uniswap-v3-periphery/contracts/libraries/TransferHelper.sol";
import "./setup/TestSetup.t.sol";

contract TestUniswapIntegration is TestForkSetup {
    uint8 USDC_DECIMALS = 6;

    function setUp() public virtual override {
        string memory MAINNET_FORK_RPC_URL = vm.envString("MAINNET_RPC_URL");
        mainnetFork = vm.createFork(MAINNET_FORK_RPC_URL);
        vm.selectFork(mainnetFork);
    }

    function testSwapWethUsdc() public {
        vm.deal(user1, 1 ether);
        vm.startPrank(user1);
        IWETH9(WETH).deposit{value: 1 ether}();
        uint256 wethBalance = IWETH9(WETH).balanceOf(user1);
        assertEq(wethBalance, 1 ether);
        uint256 amountIn = 1 ether;
        address wethUsdcPool = 0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8;
        TransferHelper.safeApprove(WETH, address(swapRouter), amountIn);
        ISwapRouter(swapRouter).exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: WETH,
                tokenOut: USDC,
                fee: 3000,
                recipient: user1,
                deadline: block.timestamp + 100,
                amountIn: amountIn,
                amountOutMinimum: 1000 * 10 ** USDC_DECIMALS,
                sqrtPriceLimitX96: 0
            })
        );
        vm.stopPrank();
        uint256 usdcBalance = IERC20(USDC).balanceOf(user1);
        assertTrue(usdcBalance > 1000 * 10 ** USDC_DECIMALS);
    }
}
