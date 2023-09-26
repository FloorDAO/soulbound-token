// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from 'forge-std/Test.sol';
import {FloorSoulbound} from '../src/FloorSoulbound.sol';

contract FloorSoulboundTest is Test {

  FloorSoulbound sbt;

  address alice;
  address bob;
  address carol;

  function setUp() public {
    // Set up a small pool of test users
    alice = payable(address(uint160(uint(1))));
    bob = payable(address(uint160(uint(2))));
    carol = payable(address(uint160(uint(3))));

    sbt = new FloorSoulbound('Floor Soulbound Token', 'FloorSBT', 'https://base.uri/');
    sbt.safeMint(alice, 0);
  }

  function test_CanGetSoulboundMetadata() public {
    assertEq(sbt.name(), 'Floor Soulbound Token');
    assertEq(sbt.symbol(), 'FloorSBT');
    assertEq(sbt.baseURI(), 'https://base.uri/');
  }

  function test_CanMintSingleSBT() public {
    assertEq(sbt.balanceOf(alice), 1);
    assertEq(sbt.balanceOf(bob), 0);

    assertEq(sbt.ownerOf(0), alice);
  }

  function test_CannotMintIfNotContractOwner(address minter) public {
    vm.assume(minter != address(this));

    vm.startPrank(minter);
    vm.expectRevert('Ownable: caller is not the owner');
    sbt.safeMint(minter, 0);
    vm.stopPrank();
  }

  function test_CannotMintTwiceToSameAddress(address recipient, uint tokenId) public {
    vm.assume(tokenId > 1);
    vm.assume(recipient != address(0));
    vm.assume(recipient != alice);

    sbt.safeMint(recipient, 1);

    vm.expectRevert('MNT01');
    sbt.safeMint(recipient, tokenId);
  }
  
  function test_CannotMintToZeroAddress(uint tokenId) public {
    vm.expectRevert('ERC721: address zero is not a valid owner');
    sbt.safeMint(address(0), tokenId);
  }

  function test_CannotMintSameTokenIdTwice(uint tokenId) public {
    vm.assume(tokenId > 0);

    sbt.safeMint(bob, tokenId);

    vm.expectRevert('MNT02');
    sbt.safeMint(carol, tokenId);
  }

  function test_CanBurnSoulboundToken() public {
    vm.prank(alice);
    sbt.burn(0);

    assertEq(sbt.balanceOf(alice), 0);

    vm.expectRevert('ERC721: invalid token ID');
    sbt.ownerOf(0);
  }

  function test_CannotBurnSoulboundTokenThatIsNotOwned(uint tokenId) public {
    vm.assume(tokenId > 0);

    sbt.safeMint(bob, tokenId);
    assertEq(sbt.balanceOf(bob), 1);

    vm.startPrank(alice);
    vm.expectRevert('BRN01');
    sbt.burn(tokenId);
    vm.stopPrank();

    assertEq(sbt.balanceOf(bob), 1);
  }

  function test_LockedStatusSetToTrueWhenMinted(uint tokenId) public {
    vm.assume(tokenId > 0);

    sbt.safeMint(bob, tokenId);
    assertTrue(sbt.locked(tokenId));
  }

  function test_CannotGetLockedStatusOfNonExistentToken(uint tokenId) public {
    vm.assume(tokenId > 0);

    vm.expectRevert('ERC721: invalid token ID');
    sbt.locked(tokenId);
  }

  function invariant_CannotSafeTransferToken() public {
    // Prevent the burn call from being made
    excludeArtifact('burn');

    // No matter what is run before, apart from a burn call, Alice always still
    // owns the token.
    assertEq(sbt.ownerOf(0), alice);
  }

  /**
   * To aid recognition that an EIP-721 token implements "soulbinding" via this EIP
   * upon calling EIP-721's `supportsInterface(bytes4 interfaceID) must return true.
   */
  function test_CanGetSupportsInterface() public {
    bytes4 goodInterface = 0xb45a3c0e; // IERC5192
    assertTrue(sbt.supportsInterface(goodInterface));
  }

}
