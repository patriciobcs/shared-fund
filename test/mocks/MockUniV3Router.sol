// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "uniswap-v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./MockERC20.sol";

/**
 * @title MockUniV3Router
 * @notice Based on the SwapRouter contract
 * @notice Use this contract when you need to test
 * other contract's ability to perform swaps using pools, but how the swap is performed
 * is not important
 */
contract MockUniV3Router {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    uint256 public constant version = 0;

    mapping(address => uint256) public tokenUsdPrice;
    mapping(uint256 => uint256) public getTimestamp;
    mapping(uint256 => uint256) private getStartedAt;

    constructor() {}

    function registerTokenPrice(address _token, uint256 _price) public {
        tokenUsdPrice[_token] = _price;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256) {
        uint256 fromPrice = tokenUsdPrice[params.tokenIn];
        uint256 toPrice = tokenUsdPrice[params.tokenOut];

        uint256 amountIn = params.amountIn;
        uint256 amountOut = amountIn * fromPrice / toPrice;

        IMockERC20(params.tokenIn).reduceUserBalance(msg.sender, amountIn);
        IMockERC20(params.tokenOut).increaseUserBalance(msg.sender, amountOut);

        return amountOut;
    }
}
