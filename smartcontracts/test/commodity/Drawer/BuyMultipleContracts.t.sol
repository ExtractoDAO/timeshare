// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {InsufficientAmount} from "../../../src/extracto/facet/commodity/v2.0.0/Commodity.Auth.sol";
import {Commodity} from "../../../src/extracto/facet/commodity/v2.0.0/Commodity.sol";
import {Future} from "../../../src/extracto/facet/future/Future.sol";
import {BaseSetup} from "../../BaseSetup.t.sol";

/*//////////////////////////////////////////////////////////////
            Validate the `creation` of Future
//////////////////////////////////////////////////////////////*/

contract BuyContractsDrawer is BaseSetup {
    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    /*
    # Scenary: Buy 100 Contracts
        - Given: the contract purchase
        - When: should generate 100 contracts
        - Then: Show all contracts in address drawer
    */
    function test_buy_100_contracts(uint256 amount, address newInvestor) public {
        uint256 total_test = 100;
        vm.assume(10e18 < amount && amount < 500 * 1e18);
        vm.assume(newInvestor != address(0x0) && newInvestor != investor);

        for (uint256 i = 0; i < total_test; i++) {
            vm.prank(controller);
            usdc.transfer(newInvestor, amount);
            uint256 balanceBefore = usdc.balanceOf(newInvestor);

            vm.prank(newInvestor);
            usdc.approve(address(diamond), amount);
            h.createFuture(newInvestor, address(usdc), amount);

            assertEq(balanceBefore - amount, usdc.balanceOf(newInvestor));
        }

        address[] memory futures = h.fullDrawer();
        assertEq(futures.length, total_test);

        for (uint256 i = 0; i < total_test; i++) {
            (address _investor,, uint256 _kg,) = h.getContractByAddress(futures[i]);
            future = Future(futures[i]);
            assertEq(future.getKg(), _kg);
            assertEq(future.investor(), _investor);
            assertEq(future.dao(), address(diamond));
        }
    }

    // TODO: docs
    function test_buy_futures_insufficient_amount() public {
        uint256 amount = 0; // 197.123456 xUSD
        vm.prank(investor);
        usdc.approve(address(diamond), amount);

        vm.expectRevert(abi.encodeWithSelector(InsufficientAmount.selector, amount, 10 * 10 ** usdc.decimals()));
        h.createFuture(investor, address(usdc), amount);
    }
}
