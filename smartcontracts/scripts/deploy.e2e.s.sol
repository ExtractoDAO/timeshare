// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Commodity} from "../src/extracto/facet/commodity/v2.0.0/Commodity.sol";
import {COW} from "../src/token/COW.sol";
import {MockToken} from "../test/MockToken.t.sol";
import "../lib/forge-std/src/Script.sol";

contract DeployE2E is Script {
    function bytes2uint(bytes32 b) public pure returns (uint256 result) {
        result = uint256(b);
    }

    // bytes32 privateKey = hex"ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
    bytes32 privateKey = vm.envBytes32("LOCAL_PRIVATE_KEY");
    address dao = vm.addr(bytes2uint(privateKey));
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
        vm.startBroadcast(bytes2uint(privateKey));
        // vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        busd = new MockToken("BUSD", supply * 1e18, 18);
        tokens.push(address(busd));
        decimals.push(18);
        usdt = new MockToken("USDT", supply * 1e18, 18);
        tokens.push(address(usdt));
        decimals.push(18);
        xusd = new MockToken("xUSD", supply * 1e6, 6);
        tokens.push(address(xusd));
        decimals.push(6);
        usdc = new MockToken("USDC", supply * 1e18, 18);
        tokens.push(address(usdc));
        decimals.push(18);

        cow = new COW();

        Commodity extracto =
        new Commodity(tokens, decimals, locktime, supply * 1e18, buyKgPrice, sellKgPrice, activateSells, dao, address(cow));
        cow.setDao(address(extracto));
        extracto.updateYieldFarming(yield);

        console.log("Commodity Commodity:", address(extracto));
        console.log("COW address:", address(cow));
        console.log("BUSD address:", address(busd));
        console.log("USDT address:", address(usdt));
        console.log("USDC address:", address(usdc));
        console.log("xUSD  address:", address(xusd));
        vm.stopBroadcast();
    }
}
