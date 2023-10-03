// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

error FunctionNotSupported();

/**
 * Soulbound token (SBT) distributed to all holders that didn't rage quit.
 */
contract FloorSoulbound is ERC1155, Ownable {
    using Strings for uint;

    /// Token metadata
    string private baseURI;
    string private baseURISuffix;
    
    /**
     * Creates our base ERC1155 with metadata.
     * 
     * @dev As we override the `uri`, we don't need to pass this to {ERC1155}.
     */
    constructor(string memory _base, string memory _suffix) ERC1155('') {
        baseURI = _base; 
        baseURISuffix = _suffix;
    }

    /**
     * Allows the metadata URI to be updated if asset paths require change.
     */
    function setURI(string calldata _base, string calldata _suffix) external onlyOwner {
        baseURI = _base;
        baseURISuffix = _suffix;
    }

    /**
     * Allows the contract owner to mint a soulbound token to a recipient.
     * 
     * @dev Ensures that the recipient does not currently own the token.
     */
    function airdrop(uint tier, address[] calldata holders) external onlyOwner {
        for (uint i; i < holders.length;) {
            if (balanceOf(holders[i], tier) == 0) {
                _mint(holders[i], tier, 1, '');
            }

            unchecked { ++i; }
        }
    }

    /**
     * Allows the holder of the Soulbound token to burn.
     */
    function burn(uint tier) external {
        _burn(msg.sender, tier, 1);
    }

    /**
     * Determines the metadata URI based on the tier.
     */
    function uri(uint tier) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, tier.toString(), baseURISuffix));
    }

    /*
     * All functions having to do with the transfer of the NFT's have been overridden.
     * Although the approval functions don't need to be overridden, there is no use 
     * for them, so I am overriding to save users gas in case they try and execute them.
     */
    function setApprovalForAll(address, bool) public pure override {
        revert FunctionNotSupported();
    }

    function safeTransferFrom(address, address, uint, uint, bytes memory) public pure override {
        revert FunctionNotSupported();
    }

    function safeBatchTransferFrom(address, address, uint[] memory, uint[] memory, bytes memory) public pure override {
        revert FunctionNotSupported();
    }
}
