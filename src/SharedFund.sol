// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "openzeppelin-contracts/utils/Counters.sol";
import "openzeppelin-contracts/token/ERC721/ERC721.sol";

contract SharedFund is ERC721 {
    using Counters for Counters.Counter;

    Counters.Counter private tokenIds;

    // Mapping from token ID to share owned.
    mapping(uint256 => uint256) public shares;

    mapping(address => uint256) public owners;

    address[] public ownersList;

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
        owners[recipient] = newItemId;
        ownersList.push(recipient);
        return newItemId;
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
        owners[to] = tokenId;
    }

    struct OwnerData {
        address owner;
        uint256 tokenId;
        uint256 share;
    }

    function getOwners() public view returns (OwnerData[] memory) {
        OwnerData[] memory ownersData = new OwnerData[](ownersList.length);
        for (uint256 i = 0; i < ownersList.length; i++) {
            ownersData[i].owner = ownersList[i];
            ownersData[i].tokenId = tokenIdOf(ownersData[i].owner);
            ownersData[i].share = shareOf(ownersData[i].tokenId );
        }
        return ownersData;
    }

    /**
     * @notice Returns the share owned by `owner`.
     * @dev See {IERC721-balanceOf}.
     *
     */
    function shareOf(uint256 tokenId) public view returns (uint256) {
        return shares[tokenId];
    }

    function tokenIdOf(address owner) public view returns (uint256) {
        return owners[owner];
    }

    function totalSupply() public view returns (uint256) {
        return tokenIds.current();
    }
}
