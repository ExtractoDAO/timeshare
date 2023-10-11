// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Commodity} from "../src/extracto/commodity/Commodity.sol";
import {MockToken} from "../test/MockToken.t.sol";
import {COW} from "../src/token/ERC20.sol";
import "../lib/forge-std/src/Script.sol";

contract Local is Script {
    address dao = address(0x01);
    uint256 buyKgPrice = 1_91 * 1e16;
    uint256 sellKgPrice = 1_91 * 1e16;
    uint256 supply = 1_000_000;
    uint256 locktime = 5;
    uint8 yield = 35;
    bool activateSells = true;

    address[] tokens;
    uint8[] decimals;

    COW cow;
    MockToken busd;
    MockToken usdc;
    MockToken usdt;
    MockToken xusd;

    function run() external {
        vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

        Commodity extracto =
            new Commodity(tokens, decimals, locktime, supply, buyKgPrice, sellKgPrice, activateSells, dao, address(cow));

        vm.stopBroadcast();
    }
}
