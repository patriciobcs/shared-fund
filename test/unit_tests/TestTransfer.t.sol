// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./setup/TestSetup.t.sol";

contract TestTransfer is TestSetup {
    /// @dev Tests transferring an NFT to a user that doesn't own an NFT.
    ///      The user receiving the NFT should be able to deposit into the fund for his received NFT.
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
