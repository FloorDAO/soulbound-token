// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from 'forge-std/Test.sol';
import {FloorSoulbound} from '../src/FloorSoulbound.sol';

contract FloorSoulboundTest is Test {

  /// Define our soulbound token contract
  FloorSoulbound sbt;

  /// Set up some test users
  address alice;
  address bob;
  address carol;

  /// Define our expected tiers
  uint TIER_GOLD = 1;
  uint TIER_SILVER = 2;
  uint TIER_BRONZE = 3;

  function setUp() public {
    // Set up a small pool of test users
    alice = payable(address(uint160(uint(1))));
    bob = payable(address(uint160(uint(2))));
    carol = payable(address(uint160(uint(3))));

    sbt = new FloorSoulbound('https://base.uri/', '.json');
  }

  function test_CanGetTokenMetadata() public {
    string memory uri = sbt.uri(TIER_GOLD);
    assertEq(uri, 'https://base.uri/1.json');

    uri = sbt.uri(TIER_SILVER);
    assertEq(uri, 'https://base.uri/2.json');
  }

  function test_CanMintSingleSBT() public {
    assertEq(sbt.balanceOf(alice, TIER_GOLD), 0);
    assertEq(sbt.balanceOf(alice, TIER_SILVER), 0);
    assertEq(sbt.balanceOf(alice, TIER_BRONZE), 0);
    assertEq(sbt.balanceOf(bob, TIER_GOLD), 0);

    sbt.airdrop(TIER_GOLD, _singleRecipient(alice));

    assertEq(sbt.balanceOf(alice, TIER_GOLD), 1);
    assertEq(sbt.balanceOf(alice, TIER_SILVER), 0);
    assertEq(sbt.balanceOf(alice, TIER_BRONZE), 0);
    assertEq(sbt.balanceOf(bob, TIER_GOLD), 0);
  }

  function test_CanMintToMultipleRecipients() public {
    address[] memory recipients = new address[](3);
    recipients[0] = alice;
    recipients[1] = bob;
    recipients[2] = carol;

    sbt.airdrop(TIER_GOLD, recipients);
  }

  function test_CannotMintSameTokenToSameUser() public {
    sbt.airdrop(TIER_GOLD, _singleRecipient(alice));
    assertEq(sbt.balanceOf(alice, TIER_GOLD), 1);

    sbt.airdrop(TIER_GOLD, _singleRecipient(alice));
    assertEq(sbt.balanceOf(alice, TIER_GOLD), 1);
  }

  function test_CanMintMultiplerTiersToSameUser() public {
    sbt.airdrop(TIER_GOLD, _singleRecipient(alice));
    sbt.airdrop(TIER_SILVER, _singleRecipient(alice));
    sbt.airdrop(TIER_BRONZE, _singleRecipient(alice));
  }

  function test_CannotMintIfNotContractOwner(address minter) public {
    vm.assume(minter != address(this));

    vm.startPrank(minter);
    vm.expectRevert('Ownable: caller is not the owner');
    sbt.airdrop(TIER_GOLD, _singleRecipient(alice));
    vm.stopPrank();
  }
  
  function test_CannotMintToZeroAddress() public {
    vm.expectRevert('ERC1155: address zero is not a valid owner');
    sbt.airdrop(TIER_GOLD, _singleRecipient(address(0)));
  }

  function test_CanBurnSoulboundToken() public {
    sbt.airdrop(TIER_GOLD, _singleRecipient(alice));

    vm.prank(alice);
    sbt.burn(TIER_GOLD);

    assertEq(sbt.balanceOf(alice, TIER_GOLD), 0);
  }

  function test_CannotBurnSoulboundTokenThatIsNotOwned() public {
    sbt.airdrop(TIER_SILVER, _singleRecipient(alice));

    vm.startPrank(alice);
    vm.expectRevert('ERC1155: burn amount exceeds balance');
    sbt.burn(TIER_GOLD);
    vm.stopPrank();
  }

  function _singleRecipient(address recipient) internal pure returns (address[] memory recipients_) {
    recipients_ = new address[](1);
    recipients_[0] = recipient;

  }

}
