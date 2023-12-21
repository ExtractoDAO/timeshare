// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DexBaseSetup} from "./DexBaseSetup.t.sol";
import {Future} from "../../src/extracto/facet/future/Future.sol";

contract SwapThenSettle is DexBaseSetup {
    function setUp() public virtual override {
        DexBaseSetup.setUp();
    }

    /*
    Scenary: Perform swap
    - Given: investor1 buy a contract for 250.00 `USDC`.
    - And: this contract should have 130.89kg
    - And: investor1 put sell order of this contract for 500.00 `USDC`.
    - AND: investor2 put buy order of 130.89kg by 500.00 USDC
    - Then: The contract must change ownership from investor1 to investor2
    - And: investor1 should receive 500.0 USDC
    */
    function test_withdraw_after_swap(uint256 randomNonce) public {
        address investor1 = address(0x1);
        address investor2 = address(0x2);

        uint256 commodityAmount = 130_89 * 10e18; // 130.89kg
        uint256 amount = 250 * 10e18;

        vm.startPrank(controller);
        // $250USD
        usdc.transfer(investor1, amount);
        // $500USD
        usdc.transfer(investor2, amount * 2);
        vm.stopPrank();

        // Put Sell Order
        vm.prank(investor1);
        usdc.approve(address(diamond), amount);
        // buy contract by $250USD
        (address _future,) = h.createFuture(investor1, address(usdc), amount);
        future = Future(_future);
        // sell order of $500USD
        vm.prank(investor1);
        future.sell(amount * 2);

        vm.prank(investor2);
        usdc.approve(address(diamond), amount * 2);
        vm.prank(investor2);
        // buy order of $500USD
        h.buyOrder(investor2, address(usdc), commodityAmount, amount * 2, randomNonce);

        vm.roll(locktime);
        vm.prank(investor2);

    }
}
