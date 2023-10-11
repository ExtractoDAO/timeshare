// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../../../lib/forge-std/src/Script.sol";
import {Commodity} from "../../../../src/extracto/facet/commodity/Commodity.sol";
import {Future} from "../../../../src/extracto/facet/future/Future.sol";
import {Dex, DexStorageLib} from "../../../../src/extracto/facet/dex/Dex.sol";
import {Diamond} from "../../../../src/extracto/diamond/Diamond.sol";
import {MockToken} from "../../../../test/MockToken.t.sol";

abstract contract Data is Script {
    bytes32 controllerPrivateKey =
        hex"ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
    bytes32 guessPrivatekey =
        hex"59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d";
    address diamond = 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707;

    Commodity commodity = Commodity(diamond);
    Dex dex = Dex(diamond);
    MockToken usdc = MockToken(0x5FbDB2315678afecb367f032d93F642f64180aa3);

    function bytes2uint(bytes32 b) public pure returns (uint256 result) {
        result = uint256(b);
    }

    constructor() {}
}

abstract contract Helper is Data {
    bytes payload;
    bytes4 fn;

    constructor() Data() {}

    function diamondApprove(uint256 allowance) public {
        usdc.approve(address(diamond), allowance);
    }

    function buyNewContract(uint256 allowance) public returns (address) {
        fn = bytes4(keccak256(bytes("createFuture(address,uint256)")));
        payload = abi.encodeWithSelector(fn, address(usdc), allowance);

        (bool ok, bytes memory data) = address(diamond).call(payload);
        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            (address future, ) = abi.decode(data, (address, uint256));
            return future;
        }
    }

    function sellOrder(address _future, uint256 price) public returns (bytes32) {
        Future future = Future(_future);
        return future.sell(price);
    }

    function transfer(address to, uint256 amount) public {
        usdc.transfer(to, amount);
    }

    function buyOrder(uint256 price, uint256 commodityAmount) public {
        dex.buyOrder(address(usdc), commodityAmount, price, uint256(12));
    }

    function getOrderBook() public returns (bool) {
        bool result;
        bool ok;
        bytes memory data;

        fn = bytes4(keccak256(bytes("sellOrders()")));
        payload = abi.encodeWithSelector(fn);

        (ok, data) = address(diamond).call(payload);
        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            DexStorageLib.Order[] memory orderbook = abi.decode(
                data,
                (DexStorageLib.Order[])
            );
            result = orderbook.length == 0;
        }
        fn = bytes4(keccak256(bytes("buyOrders()")));
        payload = abi.encodeWithSelector(fn);

        (ok, data) = address(diamond).call(payload);
        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            DexStorageLib.Order[] memory orderbook = abi.decode(
                data,
                (DexStorageLib.Order[])
            );
            result = orderbook.length == 0;
        }

        return result;
    }
}

contract OrderBook is Helper {
    constructor() Helper() {}

    function run() external {
        vm.startBroadcast(bytes2uint(controllerPrivateKey));

        // vender contrato
        sellOrder(0x61c36a8d610163660E21a8b7359e1Cac0C9133e1, 1500 * 10e18);

        // transferir saldo de A->B
        transfer(0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 1500 * 10e18);
        vm.stopBroadcast();

        // colocar ordem de compra
        vm.startBroadcast(bytes2uint(guessPrivatekey));
        diamondApprove(1500 * 10e18);
        buyOrder(1500 * 10e18, 1);

        // ver se o orderbook esta empty
        console.log(getOrderBook());

        vm.stopBroadcast();
    }
}
