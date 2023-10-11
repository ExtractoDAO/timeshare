// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {CommodityStorageLib} from "../../../../src/extracto/diamond/libraries/Lib.Commodity.sol";

contract NewContract {
    constructor() {}

    function getYieldFarming() public view returns (uint256 yieldFarming) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        yieldFarming = lib.yieldFarming + 32;
    }

    function init(address owner, uint256 x) external {}
}
