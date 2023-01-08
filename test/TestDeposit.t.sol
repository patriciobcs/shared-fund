// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./setup/TestSetup.sol";

contract TestDeposit is TestSetup {
    function testDepositOneUser() public {
        deposit(user1, 1, 1 ether);
        uint256 share = portfolio.shareOf(1);

        assertEq(portfolio.shareOf(1), PERCENTAGE_FACTOR);
    }

    function testDepositTwoUsers() public {
        deposit(user1, 1, 1 ether);
        deposit(user2, 2, 1 ether);
        assertEq(portfolio.shareOf(1), PercentageMath.HALF_PERCENTAGE_FACTOR);
        assertEq(portfolio.shareOf(2), PercentageMath.HALF_PERCENTAGE_FACTOR);
    }

    function testDepositThreeUsers() public {
        deposit(user1, 1, 1 ether);
        deposit(user2, 2, 1 ether);
        deposit(user3, 3, 1 ether);
        uint256 oneThirdPercentageFactor = PercentageMath.PERCENTAGE_FACTOR / 3;
        assertEq(portfolio.shareOf(1), oneThirdPercentageFactor);
        assertEq(portfolio.shareOf(2), oneThirdPercentageFactor);
        assertEq(portfolio.shareOf(3), oneThirdPercentageFactor);
    }

    function testDepositNotShareOwner() public {
        vm.expectRevert("You are not the owner of this share");
        deposit(address(0x18023745), 2, 1 ether);
    }

    function testDepositTokenTwice() public {
        deposit(user1, 1, 1 ether);
        deposit(user2, 2, 1 ether);
        deposit(user2, 2, 1 ether);
        assertApproxEqAbs(portfolio.shareOf(2), 2 * PercentageMath.PERCENTAGE_FACTOR / 3, 1);
    }

    function testTransferShare() public {
        deposit(user1, 1, 1 ether);
        deposit(user2, 2, 1 ether);
        vm.startPrank(user2);
        portfolio.transferFrom(user2, user3, 2);
        vm.stopPrank();
        assertEq(portfolio.ownerOf(2), user3);
        // user 3 should be able to deposit for his share
        deposit(user3, 2, 1 ether);
    }
}
