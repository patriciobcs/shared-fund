// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../../src/SharedFund.sol";

contract TestInvites is Test {
    SharedFund sharedFund;

    function setUp() public {
        sharedFund = new SharedFund();
    }

    function testInviteOk() public {
        address user = address(0x123);
        uint256 tokenId = sharedFund.invite(user);
        assertEq(sharedFund.ownerOf(tokenId), user, "User should be the owner of the token");
    }

    function testInviteErrorAlreadyInvited() public {
        testInviteOk();
        address user = address(0x123);
        vm.expectRevert("User already a member");
        sharedFund.invite(user);
    }
}
