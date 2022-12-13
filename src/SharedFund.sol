// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract SharedFund is ERC721 {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Mapping from token ID to share owned.
    // expressed in bps (basis points). 100% = 10000 bps
    mapping(uint256 => uint256) private _shares;

    constructor() ERC721("SharedFund", "SHAFU"){}

    /// @notice invites a user to join the fund
    /// @param user the address of the user to invite
    /// @return the token ID of the newly minted token
    function invite(address user) public returns (uint256){
        //TODO verify signatures
        require(balanceOf(user)==0, "User already a member");
        return _mint(user);
    }

    /// @notice Mints a new token.
    /// @param recipient The address that will own the minted token
    /// @return tokenId The token id of the minted token
    function _mint(address recipient) internal returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(recipient, newItemId);
        _shares[newItemId] = 0;
        return newItemId;
    }

    function deposit() public payable {
        // verify that the sender is the owner of a token
        require(balanceOf(msg.sender) != 0, "SharedFund: deposit from non-owner");
        uint256 deposited_amount = msg.value;
        //TODO update share with chainlink oracle depending on amount deposited

    }
}