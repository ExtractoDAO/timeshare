// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Commodity} from "../src/extracto/commodity/Commodity.sol";
import "../lib/forge-std/src/Script.sol";

contract Run is Script {
    bytes32 privateKey = hex"ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
    Commodity ext = Commodity(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);
    address investor = vm.addr(bytes2uint(privateKey));

    function bytes2uint(bytes32 b) public pure returns (uint256 result) {
        result = uint256(b);
    }

    function run() external {
        vm.startBroadcast(bytes2uint(privateKey));

        console.log(investor);
        ext.updateActive(false);

        vm.stopBroadcast();
    }
}
