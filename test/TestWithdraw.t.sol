// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./setup/TestSetup.sol";

contract TestDeposit is TestSetup {
    function testWithdrawOneUserAll() public {
        deposit(user1, 1, 1 ether);
        vm.startPrank(user1);
        portfolio.withdraw(1, PERCENTAGE_FACTOR);
        // 100% of the share
        vm.stopPrank();
        assertEq(portfolio.shareOf(1), 0);
    }

    function testWithdrawOneUserHalf() public {
        deposit(user1, 1, 1 ether);
        vm.startPrank(user1);
        portfolio.withdraw(1, PercentageMath.HALF_PERCENTAGE_FACTOR);
        assertEq(portfolio.shareOf(1), PERCENTAGE_FACTOR);
        assertEq(portfolio.getPortfolioValue(), 1000 * WAD);
    }

    function testWithdrawTwoRebalanced() public {
        deposit(user1, 1, 1 ether);
        deposit(user2, 2, 1 ether);
        vm.startPrank(user1);
        portfolio.withdraw(1, PercentageMath.HALF_PERCENTAGE_FACTOR);
        assertApproxEqAbs(portfolio.shareOf(1), PERCENTAGE_FACTOR / 3, 1);
        assertApproxEqAbs(portfolio.shareOf(2), 2 * PERCENTAGE_FACTOR / 3, 1);
        assertEq(portfolio.getPortfolioValue(), 3000 * 10 ** 18);
        vm.stopPrank();
    }
}
