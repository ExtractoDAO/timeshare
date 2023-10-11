// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DexBaseSetup} from "./DexBaseSetup.t.sol";
import {DexStorageLib} from "../../src/extracto/diamond/libraries/Lib.Dex.sol";

contract BuyOrders is DexBaseSetup {
    function setUp() public virtual override {
        DexBaseSetup.setUp();
    }

    /*
    # Scenary: Put a single Buy Order
        - Give: that the a investor buy contract
        - When: see the order book
        - Then: should have 1 bid order
    */
    function test_length_of_bid_book(uint256 randomNonce) public {
        vm.assume(investor != address(0x0));
        uint256 amount = 11 * 10e18;

        uint256 commodityAmount = 5759 * 10e16; // 57.59kg
        vm.label(investor, string(abi.encodePacked("new investor")));

        vm.prank(controller);
        usdc.transfer(investor, amount);

        vm.prank(investor);
        usdc.approve(address(diamond), amount);
        h.buyOrder(investor, address(usdc), commodityAmount, amount, randomNonce);

        DexStorageLib.Order[] memory bids = h.buyOrders();
        assertEq(bids.length, 1);

        assertApproxEqRel(bids[0].commodityAmount, commodityAmount, 10e14, "commodityAmount dont match");
        assertEq(bids[0].tokenAddress, address(usdc), "token addres dont match");
        assertEq(bids[0].investor, investor, "investor dont match");
        assertEq(bids[0].future, address(0x0), "future dont match");
        assertEq(bids[0].amount, amount, "amount dont match");

        /* JOEL
            Get event `BuyOrder`
        */
    }
}
