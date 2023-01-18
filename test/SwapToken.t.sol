pragma solidity ^0.8.0;

import "../src/SwapToken.sol";
import "forge-std/Test.sol";

contract SwapTokenTest is Test{

    SwapToken public swap;

    function setUp() public {
        swap = new SwapToken(new ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564));
    }

    function testSwap() public {

        assertTrue();
    }

}