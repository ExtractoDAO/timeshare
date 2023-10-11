// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {MockToken} from "../test/MockToken.t.sol";
import "../lib/forge-std/src/Script.sol";

contract TOKEN is Script {
    MockToken xusd;

    function run() external {
        vm.startBroadcast(vm.envUint("LOCAL_PRIVATE_KEY"));

        xusd = new MockToken("xUSD", 10_000_000 * 1e6, 6);
        console.log("xUSD address:", address(xusd));

        vm.stopBroadcast();
    }
}
