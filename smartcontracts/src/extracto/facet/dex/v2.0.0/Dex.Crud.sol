// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DexStorageLib} from "../../../diamond/libraries/Lib.Dex.sol";
import {Utils} from "./Dex.Utils.sol";

abstract contract Crud is Utils {
    constructor() Utils() {}

    function sellOrders() external view returns (DexStorageLib.Order[] memory) {
        return filterOrdersByType(DexStorageLib.OrderType.Sell);
    }

    function buyOrders() external view returns (DexStorageLib.Order[] memory) {
        return filterOrdersByType(DexStorageLib.OrderType.Buy);
    }

    function orderBook() external view returns (DexStorageLib.Order[] memory) {
        DexStorageLib.Storage storage lib = DexStorageLib.getDexStorage();
        return lib.orderBook;
    }
}
