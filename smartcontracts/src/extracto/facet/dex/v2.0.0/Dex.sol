// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {CommodityStorageLib} from "../../../diamond/libraries/Lib.Commodity.sol";
import {DexStorageLib} from "../../../diamond/libraries/Lib.Dex.sol";
import {ERC20} from "../../../../token/ERC20.sol";
import {Future} from "../../future/Future.sol";
import "../../../../utils/math/UD60x18.sol";
import {Crud} from "./Dex.Crud.sol";


contract Dex is Crud {
    constructor() Crud() {}

    function sellOrder(address investor, uint256 amount) external returns (bytes32 id) {
        address future = msg.sender;
        zeroAddr(investor);
        zeroAddr(future);
        onlyFutures(future);
        onlyNonListed(future);
        onlyNotBurnedFutures(future);
        onlyOwnerOfFutures(investor, future);

        DexStorageLib.Storage storage lib = DexStorageLib.getDexStorage();
        CommodityStorageLib.Storage storage libCommodity = CommodityStorageLib.getCommodityStorage();

        uint256 rawCommodityAmount = libCommodity.contracts[future].commodityAmount;
        uint256 commodityAmount = unwrap(floor(ud60x18(rawCommodityAmount)));
        uint256 randNonce = rawCommodityAmount - commodityAmount;

        DexStorageLib.Order memory sell =
            mountOrder(commodityAmount, amount, address(0x0), future, investor, DexStorageLib.OrderType.Sell, randNonce);

        (bool result, uint256 index) = matchOrder(sell.amount, sell.commodityAmount, DexStorageLib.OrderType.Buy);

        if (result) {
            swap(lib.orderBookMatch[sell.amount][sell.commodityAmount][index], sell);
        } else {
            lib.orderBookMatch[sell.amount][sell.commodityAmount].push(sell);
            lib.ordersByInvestor[sell.investor].push(sell);
            lib.orderById[sell.id] = sell;
            lib.orderBook.push(sell);
            id = sell.id;

            emit SellOrder(id, sell.future, sell.amount, sell.commodityAmount);
        }
    }

    function buyOrder(address tokenAddress, uint256 commodityAmount, uint256 amount, uint256 randNonce)
        external
        returns (bytes32 id)
    {
        address investor = msg.sender;
        onlyStableCoins(tokenAddress);
        validateAllowance(tokenAddress, investor, address(this), amount);

        DexStorageLib.Storage storage lib = DexStorageLib.getDexStorage();

        DexStorageLib.Order memory buy = mountOrder(
            commodityAmount, amount, tokenAddress, address(0x0), investor, DexStorageLib.OrderType.Buy, randNonce
        );

        (bool result, uint256 index) = matchOrder(buy.amount, buy.commodityAmount, DexStorageLib.OrderType.Sell);

        if (result) {
            swap(buy, lib.orderBookMatch[buy.amount][buy.commodityAmount][index]);
        } else {
            lib.orderBookMatch[buy.amount][buy.commodityAmount].push(buy);
            lib.ordersByInvestor[buy.investor].push(buy);
            lib.orderById[buy.id] = buy;
            lib.orderBook.push(buy);
            id = buy.id;

            emit BuyOrder(id, buy.amount, buy.commodityAmount);
        }
    }

    function cancelOrderForWithdraw(bytes32 orderId, address investor) external {
        zeroAddr(investor);
        onlyTrueOrder(orderId);
        onlyOwnerOfOrder(investor, orderId);
        onlyFutures(msg.sender);

        removeOrder(investor, orderId);

        DexStorageLib.Storage storage lib = DexStorageLib.getDexStorage();
        DexStorageLib.Order storage order = lib.orderById[orderId];

        emit CancelOrder(orderId, order.amount, order.commodityAmount, order.typed);
    }

    function cancelOrder(bytes32 orderId) external {
        address investor = msg.sender;
        zeroAddr(investor);
        onlyTrueOrder(orderId);
        onlyOwnerOfOrder(investor, orderId);

        removeOrder(investor, orderId);

        DexStorageLib.Storage storage lib = DexStorageLib.getDexStorage();
        DexStorageLib.Order storage order = lib.orderById[orderId];

        emit CancelOrder(orderId, order.amount, order.commodityAmount, order.typed);
    }

    function removeOrder(address investor, bytes32 orderId) internal {
        DexStorageLib.Storage storage lib = DexStorageLib.getDexStorage();
        DexStorageLib.Order storage order = lib.orderById[orderId];

        delete lib.orderBookMatch[order.amount][order.commodityAmount];
        delete lib.orderById[orderId];

        DexStorageLib.Order[] storage orders = lib.ordersByInvestor[investor];
        for (uint256 i = 0; i < orders.length; i++) {
            if (orders[i].id == orderId) {
                orders[i] = orders[orders.length - 1];
                orders.pop();
                break;
            }
        }

        for (uint256 i = 0; i < lib.orderBook.length; i++) {
            if (lib.orderBook[i].id == orderId) {
                lib.orderBook[i] = lib.orderBook[lib.orderBook.length - 1];
                lib.orderBook.pop();
                break;
            }
        }
    }

    function swap(DexStorageLib.Order memory buy, DexStorageLib.Order memory sell) internal {
        CommodityStorageLib.Storage storage libCommodity = CommodityStorageLib.getCommodityStorage();

        onlyOtherInvestor(buy.investor, sell.investor);
        onlyNotBurnedFutures(sell.investor);

        removeOrder(buy.investor, buy.id);
        removeOrder(sell.investor, sell.id);

        libCommodity.contracts[sell.future].investor = buy.investor;
        CommodityStorageLib.Contract[] storage contracts = libCommodity.contractsByInvestor[sell.investor];
        for (uint256 i = 0; i < contracts.length; i++) {
            if (contracts[i].future == sell.future) {
                libCommodity.contractsByInvestor[buy.investor].push(contracts[i]);

                contracts[i] = contracts[contracts.length - 1];
                contracts.pop();
                break;
            }
        }

        validatePayment(buy.tokenAddress, buy.investor, sell.investor, sell.amount);

        Future future = Future(sell.future);
        future.swap(buy.investor);

        emit MatchOrder(sell.investor, buy.investor, sell.future, sell.amount, sell.commodityAmount);
    }
}
