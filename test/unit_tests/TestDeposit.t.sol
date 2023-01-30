// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./setup/TestSetup.t.sol";

contract TestDeposit is TestSetup {
    /// @dev Tests depositing 1 ether into the fund. The user should have 1 ether in the fund and
    ///      the share for its NFT should be equal to 100% since he's the only user in the fund.
    ///      The deposit function should wrap the ether received.
    function testDepositOneUser() public {
        deposit(user1, 1, 1 ether);
        uint256 share = portfolio.shareOf(1);

        assertEq(share, PERCENTAGE_FACTOR);
        assertEq(IERC20(WETH).balanceOf(address(portfolio)), 1 ether);
    }

    /// @dev Tests depositing 1 ether into the fund for two users. The users should have 1 ether each in the fund and
    ///      the share for their NFT should be equal to 50% since there are 2 users in the fund.
    function testDepositTwoUsers() public {
        deposit(user1, 1, 1 ether);
        deposit(user2, 2, 1 ether);
        assertEq(portfolio.shareOf(1), PercentageMath.HALF_PERCENTAGE_FACTOR);
        assertEq(portfolio.shareOf(2), PercentageMath.HALF_PERCENTAGE_FACTOR);
        assertEq(IERC20(WETH).balanceOf(address(portfolio)), 2 ether);
    }

    /// @dev Tests depositing 1 ether into the fund for three users. The users should have 1 ether each in the fund and
    ///      the share for their NFT should be equal to 33% since there are 2 users in the fund.
    function testDepositThreeUsers() public {
        deposit(user1, 1, 1 ether);
        deposit(user2, 2, 1 ether);
        deposit(user3, 3, 1 ether);
        uint256 oneThirdPercentageFactor = PercentageMath.PERCENTAGE_FACTOR / 3;
        assertEq(portfolio.shareOf(1), oneThirdPercentageFactor);
        assertEq(portfolio.shareOf(2), oneThirdPercentageFactor);
        assertEq(portfolio.shareOf(3), oneThirdPercentageFactor);
        assertEq(IERC20(WETH).balanceOf(address(portfolio)), 3 ether);
    }

    /// @dev Tests depositing 1 ether into the fund by a user that doesn't own an NFT.
    ///      The invoke should revert.
    function testDepositNotShareOwner() public {
        vm.expectRevert("CALLER_NOT_TOKEN_OWNER");
        deposit(address(0x18023745), 2, 1 ether);
    }

    /// @dev Tests depositing twice 1 ether into the fund.
    ///      The user2 should own 2/3 of the fund
    function testDepositTokenTwice() public {
        deposit(user1, 1, 1 ether);
        deposit(user2, 2, 1 ether);
        deposit(user2, 2, 1 ether);
        assertApproxEqAbs(portfolio.shareOf(2), 2 * PercentageMath.PERCENTAGE_FACTOR / 3, 1);
        assertEq(IERC20(WETH).balanceOf(address(portfolio)), 3 ether);
    }
}
