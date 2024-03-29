// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./setup/TestSetup.t.sol";

contract TestDeposit is TestSetup {
    /// @dev Tests withdrawing all of a user's shares. The user should receive ETH back and
    ///      the share for its NFT should be equal to 0.
    function testWithdrawOneUserAll() public {
        deposit(user1, 1, 1 ether);
        vm.startPrank(user1);
        portfolio.withdraw(1, PERCENTAGE_FACTOR);
        // 100% of the share
        vm.stopPrank();
        assertEq(portfolio.shareOf(1), 0);
        assertEq(IERC20(WETH).balanceOf(address(portfolio)), 0 ether);
    }

    /// @dev Tests withdrawing 50% of a user's shares. The user should receive 50% of the ETH back and
    ///      the share for its NFT should be equal to 50% since he's the only user in the fund.
    function testWithdrawOneUserHalf() public {
        deposit(user1, 1, 1 ether);
        vm.startPrank(user1);
        portfolio.withdraw(1, PercentageMath.HALF_PERCENTAGE_FACTOR);
        assertEq(portfolio.shareOf(1), PERCENTAGE_FACTOR);
        assertEq(portfolio.getPortfolioValue(), 1000 * PRICEFEED_PRECISION);
        assertEq(IERC20(WETH).balanceOf(address(portfolio)), 0.5 ether);
    }

    /// @dev Tests withdrawing 50% of a user's shares. The user should receive 50% of his ETH back and
    ///      the share for its NFT should be equal to 1/3 since there are 2 users in the fund that deposited 1 ether each.
    ///      After the withdrawal, the user should have 1/3 of the fund's value since he deposited 1/3 of the total value.
    function testWithdrawTwoRebalanced() public {
        deposit(user1, 1, 1 ether);
        deposit(user2, 2, 1 ether);
        vm.startPrank(user1);
        portfolio.withdraw(1, PercentageMath.HALF_PERCENTAGE_FACTOR);
        uint256 wethBalance = IERC20(WETH).balanceOf(address(portfolio));
        assertApproxEqAbs(portfolio.shareOf(1), PERCENTAGE_FACTOR / 3, 1);
        assertApproxEqAbs(portfolio.shareOf(2), 2 * PERCENTAGE_FACTOR / 3, 1);
        assertEq(portfolio.getPortfolioValue(), 3000 * PRICEFEED_PRECISION);
        assertEq(wethBalance, 1.5 ether);
        vm.stopPrank();
    }
}
