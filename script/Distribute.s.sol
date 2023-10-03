// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from 'forge-std/Script.sol';

import {FloorSoulbound} from '../src/FloorSoulbound.sol';

contract DistributeScript is Script {

    address[] recipients;

    FloorSoulbound floorSoulbound;

    /*
    function setUp() public {
        // @dev This will raise an error if it cannot be read
        bytes memory recipientData = vm.parseJson(
            vm.readFile('data/recipients.json')
        );

        recipients = abi.decode(recipientData, (address[]));
    }
    */

    function run() public {
        // Load our seed phrase from a protected file
        // uint privateKey = vm.envUint('PRIVATE_KEY');

        // Using the passed in the script call, has all subsequent calls (at this call
        // depth only) create transactions that can later be signed and sent onchain.
        vm.startBroadcast();

        // Deploy our contract
        floorSoulbound = new FloorSoulbound('https://token.floor.xyz/', '.json');

        // Load our whitelist users
        // floorSoulbound.airdrop(1, recipients);

        // Stop collecting onchain transactions
        vm.stopBroadcast();
    }
}
