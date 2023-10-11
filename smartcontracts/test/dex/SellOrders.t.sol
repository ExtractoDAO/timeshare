// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../src/extracto/facet/future/Future.sol";
import {DexBaseSetup} from "./DexBaseSetup.t.sol";
import {DexStorageLib} from "../../src/extracto/diamond/libraries/Lib.Dex.sol";

contract SellOrders is DexBaseSetup {
    function setUp() public virtual override {
        DexBaseSetup.setUp();
    }

    /*
    # Scenary: Put a single Sell Order
        - Give: that the a investor sell contracts
        - When: see the order book
        - Then: should have 1 ask order
    */
    function test_length_of_ask_order_book() public {
        uint256 amount = 11 * 10e18;

        vm.prank(controller);
        usdc.transfer(investor, amount);

        vm.prank(investor);
        usdc.approve(address(diamond), amount);
        (address _future, uint256 commodityAmount) = h.createFuture(investor, address(usdc), amount);

        future = Future(_future);
        vm.prank(investor);
        future.sell(amount + 1 * 10e18);

        DexStorageLib.Order[] memory asks = h.sellOrders();
        assertEq(asks.length, 1);

        assertApproxEqRel(asks[0].commodityAmount, commodityAmount, 10e14, "commodityAmount dont match");
        assertEq(asks[0].tokenAddress, address(0x0), "token addres dont match");
        assertEq(asks[0].amount, amount + 1 * 10e18, "amount dont match");
        assertEq(asks[0].investor, investor, "investor dont match");
        assertEq(asks[0].future, _future, "future dont match");
        /* JOEL
            Get event `SellOrder`
        */
    }

    /* JOEL
    # Scenary: Placing the same Sell Order twice
        - Give: that the a investor sell contract
        - When: see the order book
        - AND: he sell same contract
        - Then: should get a error `FutureAlreadyListed`
    */

    /* JOEL
    # Scenary: Self Trading Order
        - Give: that the a investor sell contract
        - When: see the order book
        - AND: put a new buy order to match with self sell order
        - Then: should get a error `SelfTradingError`
    */
}
