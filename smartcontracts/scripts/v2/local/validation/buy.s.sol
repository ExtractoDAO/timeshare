// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../../../lib/forge-std/src/Script.sol";
import {Commodity} from "../../../../src/extracto/facet/commodity/Commodity.sol";
import {Diamond} from "../../../../src/extracto/diamond/Diamond.sol";
import {MockToken} from "../../../../test/MockToken.t.sol";

abstract contract Data is Script {
    bytes32 controllerPrivateKey =
        hex"ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
    address diamond = 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707;

    Commodity commodity = Commodity(diamond);
    MockToken usdc = MockToken(0x5FbDB2315678afecb367f032d93F642f64180aa3);

    function bytes2uint(bytes32 b) public pure returns (uint256 result) {
        result = uint256(b);
    }
}

abstract contract Helper is Data {
    bytes payload;
    bytes4 fn;

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
            (address future, ) = abi.decode(
                data,
                (address, uint256)
            );
            return future;
        }
    }
}

contract Buy is Helper {
    constructor() Helper() {}

    function run() external {
        vm.startBroadcast(bytes2uint(controllerPrivateKey));

        uint256 amount = 1000 * 10e18;

        diamondApprove(amount);
        address future = buyNewContract(amount);

        console.log(future);

        vm.stopBroadcast();
    }
}
