// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.16;

import {ERC721, IERC721} from '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import {ERC721Enumerable} from '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';

import {IERC5192} from './interfaces/IERC5192.sol';

/**
 * Soulbound token (SBT) distributed to all holders that didn't rage quit.
 * 
 * @dev The implementation follows EIP-5192: Minimal Soulbound NFT.
 */
contract FloorSoulbound is ERC721, ERC721Enumerable, Ownable {
    /// @notice Emitted when the locking status is changed to locked.
    /// @dev If a token is minted and the status is locked, this event should be emitted.
    /// @param tokenId The identifier for a token.
    event Locked(uint256 tokenId);

    /// @notice Emitted when the locking status is changed to unlocked.
    /// @notice currently SBT Contract does not emit Unlocked event
    /// @dev If a token is minted and the status is unlocked, this event should be emitted.
    /// @param tokenId The identifier for a token.
    event Unlocked(uint256 tokenId);

    /// Metadata base URI
    string public baseURI;

    /// Mapping from token ID to locked status
    mapping(uint256 => bool) _locked;

    /**
     * Creates our ERC721 and defines the core metadata.
     */
    constructor(string memory name_, string memory symbol_, string memory baseURI_) ERC721(name_, symbol_) {
        baseURI = baseURI_;
    }

    /**
     * Reads the metadata base URI.
     */
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /**
     * Returns the locking status of an Soulbound Token.
     * 
     * @dev SBTs assigned to zero address are considered invalid, and queries about
     * them do throw.
     * 
     * @param tokenId The identifier for an SBT.
     */
    function locked(uint256 tokenId) external view returns (bool) {
        require(ownerOf(tokenId) != address(0));
        return _locked[tokenId];
    }

    /**
     * Allows the contract owner to mint the soulbound token to a recipient.
     * 
     * @dev Ensures that the recipient does not currently own the token and that the ID
     * of the token is not locked to prevent duplicated creation.
     */
    function safeMint(address to, uint256 tokenId) public onlyOwner {
        require(balanceOf(to) == 0, "MNT01");
        require(_locked[tokenId] != true, "MNT02");

        _locked[tokenId] = true;
        emit Locked(tokenId);

        _safeMint(to, tokenId);
    }

    /**
     * Allows the holder of the Soulbound token to burn.
     */
    function burn(uint256 tokenId) public {
        // Ensure that the caller owns the specified token ID
        require(msg.sender == ownerOf(tokenId), "BRN01");

        // Burn the token
        _burn(tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override(IERC721, ERC721) IsTransferAllowed(tokenId) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override(IERC721, ERC721) IsTransferAllowed(tokenId) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override(IERC721, ERC721) IsTransferAllowed(tokenId) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function supportsInterface(bytes4 _interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return _interfaceId == type(IERC5192).interfaceId || super.supportsInterface(_interfaceId);
    }

    modifier IsTransferAllowed(uint256 tokenId) {
        require(!_locked[tokenId]);
        _;
    }
}
