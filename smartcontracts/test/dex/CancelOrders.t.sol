// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DexStorageLib} from "../../src/extracto/diamond/libraries/Lib.Dex.sol";
import {Future} from "../../src/extracto/facet/future/Future.sol";
import {DexBaseSetup} from "./DexBaseSetup.t.sol";

contract CancelOrders is DexBaseSetup {
    function setUp() public virtual override {
        DexBaseSetup.setUp();
    }

    /*
    # Scenary: Remove Sell Order
        - Give: that a investor sell contracts
        - And: this investors cancel your order
        - When: see the order book
        - Then: should have 0 ask orders
    */
    function test_canceled_sell_order_book_length() public {
        uint256 sellAmount = 12 * 10e18;
        uint256 sellCommodityAmount = 628_20 * 10e16; // 628.20kg

        vm.prank(controller);
        usdc.transfer(investor, sellAmount);

        // Put Sell Order
        vm.prank(investor);
        usdc.approve(address(diamond), sellAmount);
        (address _future,) = h.createFuture(investor, address(usdc), sellAmount);
        future = Future(_future);
        vm.prank(investor);
        bytes32 id = future.sell(sellAmount);

        // 1 Validation
        assertEq(h.sellOrders().length, 1);

        // Cancel Sell Order
        DexStorageLib.Order memory sell;
        sell.commodityAmount = sellCommodityAmount;
        sell.amount = sellAmount;
        sell.tokenAddress = address(0x0);
        sell.future = _future;
        sell.investor = investor;
        sell.typed = DexStorageLib.OrderType.Sell;
        sell.id = id;

        h.cancelOrder(investor, sell.id);

        // 2 Validation
        assertEq(h.sellOrders().length, 0);
        /* JOEL
            Get event `CancelOrder`
        */
    }

    /*
    # Scenary: Remove Buy Order
        - Give: that a investor put a buy order contract
        - And: this investors cancel your order
        - When: see the order book
        - Then: should have 0 ask orders
    */
    function test_canceled_buy_order_book_length(uint256 randomNonce) public {
        uint256 buyCommodityAmount = 10_99 * 10e16; // 10.99kg
        uint256 buyAmount = 11 * 10e18;

        // Put Buy Order
        vm.prank(investor);
        usdc.approve(address(diamond), buyAmount);
        bytes32 id = h.buyOrder(investor, address(usdc), buyCommodityAmount, buyAmount, randomNonce);

        // 1 Validation
        assertEq(h.buyOrders().length, 1);

        // Cancel Buy Order
        DexStorageLib.Order memory buy;
        buy.commodityAmount = buyCommodityAmount;
        buy.amount = buyAmount;
        buy.tokenAddress = address(usdc);
        buy.future = address(0x0);
        buy.investor = investor;
        buy.typed = DexStorageLib.OrderType.Buy;
        buy.id = id;

        h.cancelOrder(investor, buy.id);

        // 2 Validation
        assertEq(h.buyOrders().length, 0);
    }
}
