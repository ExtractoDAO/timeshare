// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Commodity} from "../src/extracto/commodity/Commodity.sol";
import {MockToken} from "../test/MockToken.t.sol";
import "../lib/forge-std/src/Script.sol";

contract Run is Script {
    bytes32 privateKey = hex"ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
    address investor = vm.addr(bytes2uint(privateKey));
    Commodity ext = Commodity(vm.envAddress("Commodity"));
    MockToken usdc = MockToken(vm.envAddress("USDC"));

    function bytes2uint(bytes32 b) public pure returns (uint256 result) {
        result = uint256(b);
    }

    function run() external {
        vm.startBroadcast(bytes2uint(privateKey));

        usdc.approve(address(ext), 200 * 1e18);
        (address f, uint256 kg) = ext.createFuture(address(usdc), 200 * 1e18);

        console.log("Investor:", investor);
        console.log("Future address", f);
        console.log("Future kg", kg);
        vm.stopBroadcast();
    }
}
