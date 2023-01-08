// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./setup/TestSetup.sol";

contract TestTransfer is TestSetup {
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
