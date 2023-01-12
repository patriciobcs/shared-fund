import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./PriceFeedConsumer.sol";

contract SwapToken is Ownable {

    ISwapRouter public immutable swapRouter;
    uint24 public constant poolFee = 3000;
    mapping(string => address) public symbolAddress;


    constructor (ISwapRouter _swapRouter){
        swapRouter = _swapRouter;

        //Next i think we can add it through the front
        symbolAddress["USDC"] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        symbolAddress["ETH"] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        symbolAddress["BTC"] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        symbolAddress["LINK"] = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    }

    function swapTokens(address from, address to, uint256 amountIn, uint256 minOut) external returns (uint256 amountOut){

        TransferHelper.safeTransferFrom(symbolAddress[from], msg.sender, address(this), amountIn);
        TransferHelper.safeApprove(symbolAddress[from], address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: symbolAddress[from],
                tokenOut: symbolAddress[to],
                fee: poolFee,
                recipient: mg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amoutOutMinimum: minOut,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);

    }
}