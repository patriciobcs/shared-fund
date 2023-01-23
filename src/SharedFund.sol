// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "openzeppelin-contracts/utils/Counters.sol";
import "openzeppelin-contracts/token/ERC721/ERC721.sol";

contract SharedFund is ERC721 {
    using Counters for Counters.Counter;

    Counters.Counter private tokenIds;

    // Mapping from token ID to share owned.
    // expressed in wad which are decimal number with 18 decimals of precision
    // 1 wad = 1e18 = 1%
    // 100 wad = 1e20 = 100%
    mapping(uint256 => uint256) public shares;

    constructor() ERC721("SharedFund", "SHAFU") {}

    /// @notice invites a user to join the fund
    /// @param user the address of the user to invite
    /// @return the token ID of the newly minted token
    function invite(address user) public returns (uint256) {
        //TODO verify signatures
        require(balanceOf(user) == 0, "User already a member");
        return _mint(user);
    }

    /// @notice Mints a new token.
    /// @param recipient The address that will own the minted token
    /// @return tokenId The token id of the minted token
    function _mint(address recipient) internal returns (uint256) {
        tokenIds.increment();
        uint256 newItemId = tokenIds.current();
        _safeMint(recipient, newItemId);
        shares[newItemId] = 0;
        return newItemId;
    }

    /**
     * @notice Returns the share owned by `owner`.
     * @dev See {IERC721-balanceOf}.
     *
     */
    function shareOf(uint256 tokenId) public view returns (uint256) {
        return shares[tokenId];
    }

    function totalSupply() public view returns (uint256) {
        return tokenIds.current();
    }
}
