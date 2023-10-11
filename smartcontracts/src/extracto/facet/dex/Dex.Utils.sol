// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DexStorageLib} from "../../diamond/libraries/Lib.Dex.sol";
import {Auth} from "../commodity/Commodity.Auth.sol";
import "../../../utils/math/UD60x18.sol";

abstract contract Utils is Auth {
    event MatchOrder(
        address oldInvestor, address newInvestor, address future, uint256 indexed amount, uint256 commodityAmount
    );
    event CancelOrder(bytes32 id, uint256 indexed amount, uint256 commodityAmount, DexStorageLib.OrderType side);
    event SellOrder(bytes32 id, address indexed future, uint256 amount, uint256 commodityAmount);
    event BuyOrder(bytes32 id, uint256 indexed amount, uint256 commodityAmount);

    constructor() Auth() {}

    function matchOrder(uint256 amount, uint256 commodityAmount, DexStorageLib.OrderType typed)
        internal
        view
        returns (bool result, uint256 index)
    {
        DexStorageLib.Storage storage lib = DexStorageLib.getDexStorage();

        DexStorageLib.Order[] memory orders = lib.orderBookMatch[amount][commodityAmount];

        for (uint256 i = 0; i < orders.length; i++) {
            if (orders[i].typed == typed) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function filterOrdersByType(DexStorageLib.OrderType typed) internal view returns (DexStorageLib.Order[] memory) {
        DexStorageLib.Storage storage lib = DexStorageLib.getDexStorage();

        uint256 count;
        for (uint256 j = 0; j < lib.orderBook.length; j++) {
            if (lib.orderBook[j].typed == typed) {
                count++;
            }
        }

        DexStorageLib.Order[] memory orders = new DexStorageLib.Order[](count);
        uint256 i;

        for (uint256 j = 0; j < lib.orderBook.length; j++) {
            if (lib.orderBook[j].typed == typed) {
                orders[i] = lib.orderBook[j];
                i++;
            } else {
                continue;
            }
        }

        return orders;
    }

    function mountOrder(
        uint256 commodityAmount,
        uint256 amount,
        address tokenAddress,
        address future,
        address investor,
        DexStorageLib.OrderType typed,
        uint256 randNonce
    ) internal pure returns (DexStorageLib.Order memory order) {
        validateAmounts(commodityAmount, amount);

        bytes32 id =
            keccak256(abi.encodePacked(commodityAmount, tokenAddress, future, investor, amount, typed, randNonce));

        order = DexStorageLib.Order(commodityAmount, amount, tokenAddress, future, investor, typed, id);
    }
}
