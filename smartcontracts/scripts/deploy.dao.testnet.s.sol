// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Commodity} from "../src/extracto/commodity/Commodity.sol";
import {COW} from "../src/token/ERC20.sol";
import "../lib/forge-std/src/Script.sol";

contract Mumbai is Script {
    function bytes2uint(bytes32 b) public pure returns (uint256 result) {
        result = uint256(b);
    }

    bytes32 privateKey = vm.envBytes32("MUMBAI_PRIVATE_KEY");
    address dao = vm.addr(bytes2uint(privateKey));
    COW cow;
    uint256 buyKgPrice = 1_91 * 1e16;
    uint256 sellKgPrice = 1_91 * 1e16;
    uint256 supply = 100_000_000;
    uint256 locktime = 100;
    uint8 yield = 35;
    bool activateSells = true;

    address[] tokens;
    uint8[] decimals;

    function run() external {
        vm.startBroadcast(bytes2uint(privateKey));

        tokens.push(0xCc22a3bA826026210a2580aEc0e8Ade65Fc25FDd); // BUSD
        decimals.push(18);
        tokens.push(0xe2Df7F5e5df9482e98E87F95045557D44e48e590); // USDT
        decimals.push(18);
        tokens.push(0xD6c75a90F15cDb00EaA1A65989F1034D919391EE); // USDC
        decimals.push(18);
        tokens.push(0x9a3B9F1ec0Acb3Fe6d8bE16649f6C0D855C4B15C); // DAI
        decimals.push(18);
        tokens.push(0x28e38b65cf6B91645a56057C32F400833377844b); // xUSD
        decimals.push(6);

        cow = new COW();
        Commodity extracto =
            new Commodity(tokens, decimals, locktime, supply, buyKgPrice, sellKgPrice, activateSells, dao, address(cow));
        cow.setDao(address(extracto));
        extracto.updateYieldFarming(yield);

        console.log("Owner: ", dao);
        console.log("COW token: ", address(cow));
        console.log("Commodity      : ", address(extracto));

        vm.stopBroadcast();
    }
}
