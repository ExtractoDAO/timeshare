// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Commodity} from "../src/extracto/commodity/Commodity.sol";
import {COW} from "../src/token/ERC20.sol";
import "../lib/forge-std/src/Script.sol";

contract Polygon is Script {
    function bytes2uint(bytes32 b) public pure returns (uint256 result) {
        result = uint256(b);
    }

    bytes32 privateKey = vm.envBytes32("POLYGON_PRIVATE_KEY");
    address dao = address(0x5B8881d1D5Df945DF6Ec3752414cBB4c4F594556);
    uint256 sellKgPrice = 3_87 * 1e16;
    uint256 buyKgPrice = 3_87 * 1e16;
    uint256 supply = 198_000;
    uint256 locktime = 5_948_640;
    bool activateSells = true;
    uint8 yield = 14;

    address[] tokens;
    uint8[] decimals;

    Commodity extracto;
    COW cow;

    function run() external {
        vm.startBroadcast(bytes2uint(privateKey));

        // add ERC20 tokens
        tokens.push(address(0x9C9e5fD8bbc25984B178FdCE6117Defa39d2db39)); // BUSD (real)
        decimals.push(18);
        tokens.push(address(0xc2132D05D31c914a87C6611C10748AEb04B58e8F)); // USDT (real)
        decimals.push(6);
        tokens.push(address(0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063)); // DAI (real)
        decimals.push(18);
        tokens.push(address(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174)); // USDC (real)
        decimals.push(6);

        // create COW token
        cow = new COW();

        // create Commodity
        extracto =
            new Commodity(tokens, decimals, locktime, supply, buyKgPrice, sellKgPrice, activateSells, dao, address(cow));

        // set Commodity on COW token
        cow.setDao(address(extracto));

        // set Yield on Commodity
        extracto.updateYieldFarming(yield);

        // add WhitList members to Commodity

        // Lucas Oliveira = 0x4b818CA979D14EEA8E39a641bdaAee2dB3b34f6F
        extracto.addAddressWhitelist(0x4b818CA979D14EEA8E39a641bdaAee2dB3b34f6F);
        // Robson Miranda = 0x61839Df242801888ECA001246269D0C747c434Ee
        extracto.addAddressWhitelist(0x61839Df242801888ECA001246269D0C747c434Ee);
        // Joel Esteves = 0xF9eE4348dC2CD6D42b2CD9B5c5927D4854b88284
        extracto.addAddressWhitelist(0xF9eE4348dC2CD6D42b2CD9B5c5927D4854b88284);
        // Lucas guimer = 0x6E5cf3369Ea7269B712b76218EEf6442bF60ece9
        extracto.addAddressWhitelist(0x6E5cf3369Ea7269B712b76218EEf6442bF60ece9);
        // joel almeida = 0x5B8881d1D5Df945DF6Ec3752414cBB4c4F594556
        extracto.addAddressWhitelist(0x5B8881d1D5Df945DF6Ec3752414cBB4c4F594556);
        // velder = 0x719c03Dec577325fB499a06BA7eBeaD6Cf2e4cA4
        extracto.addAddressWhitelist(0x719c03Dec577325fB499a06BA7eBeaD6Cf2e4cA4);
        // edu = 0x7CA3cd22B34F34f2A895866F7f8e64Cc7Ec5eb77
        extracto.addAddressWhitelist(0x7CA3cd22B34F34f2A895866F7f8e64Cc7Ec5eb77);

        console.log("COW token: ", address(cow));
        console.log("Commodity      : ", address(extracto));

        vm.stopBroadcast();
    }
}
