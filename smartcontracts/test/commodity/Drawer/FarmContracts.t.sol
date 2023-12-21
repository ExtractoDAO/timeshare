// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {UnavailableKilos, InvalidYield} from "../../../src/extracto/facet/commodity/v2.0.0/Commodity.Auth.sol";
import {Future} from "../../../src/extracto/facet/future/Future.sol";
import {BaseSetup} from "../../BaseSetup.t.sol";

/*//////////////////////////////////////////////////////////////
        Testing `yield` applied by Dao on Future
//////////////////////////////////////////////////////////////*/

contract FarmContracts is BaseSetup {
    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    /*
    # Scenary:
     - Given: that the investor buy 361.398 USDC in kg
     - AND: the price 1.91 USD/kg does not change in the period
     - AND: the Commodity makes the yield farming of 17%
     - When: the contract unlocked
     - AND: the investor makes the withdrawal
     - Then: the investor should receive 135 kg
    */
    function test_buy_futures_farm_and_withdraw() public {
        uint256 amount = 361_398 * 1e15; // 361.398 USDC

        vm.prank(investor);
        usdc.approve(address(diamond), amount);
        (address _future,) = h.createFuture(investor, address(usdc), amount);

        future = Future(_future);
        assertEq(future.investor(), investor);

        vm.expectRevert(abi.encodeWithSelector(InvalidYield.selector, 0, 100));
        h.updateYieldFarming(deployer, 101);
        h.updateYieldFarming(deployer, 17);

        vm.roll(locktime + 1);

        vm.prank(investor);

        assertEq(cow.balanceOf(investor), 4228_35_6329999999999999);
    }

    /*
    # Scenary:
     - Given: that the investor buy 485.00 USDC in kg
     - AND: the price 4.85 USD/kg change in the period to 5.25 USD/kg
     - AND: the Commodity makes the yield farming of 19%
     - When: the contract unlocked
     - AND: the investor makes the withdrawal
     - Then: the investor should receive 119 kg
    */
    function test_buy_futures_farm_change_price_of_kg_and_withdraw() public {
        uint256 amount = 485_00 * 1e16; // 485.00 USDC
        h.updateBuyPrice(deployer, 4_85 * 1e16);

        vm.prank(investor);
        usdc.approve(address(diamond), amount);
        (address _future,) = h.createFuture(investor, address(usdc), amount);

        future = Future(_future);
        assertEq(future.investor(), investor);

        h.updateYieldFarming(deployer, 19);

        vm.roll(locktime + 1);

        h.updateSellPrice(deployer, 5_25 * 1e16);

        vm.prank(investor);

        assertEq(
            cow.balanceOf(investor),
            // 6247.5 kg
            6247_50_0000000000000000
        );
    }

    /*
    # Scenary: Update status sales:
        - Give: The contract checks whether
        - When: The contract is active or deactivated
        - Then: Must return a boolean true or false
    */
    function test_update_status_sales() public {
        h.updateActive(deployer, true);
        assertEq(h.getActivated(), true);
        assertEq(h.getTotalSupplyKG(), 1_000_000 * 1e18);

        h.updateActive(deployer, false);
        assertEq(h.getActivated(), false);
    }

    /*
    # Scenary: unavailable kilos
        - Give: The suply is 1000kg
        - When: And if you exceed this supply
        - Then: Should return error UnavailableKilos
    */
    function test_unavailable_kilos() public {
        uint256 amountHigth = 191000000 * 1e16;
        vm.prank(investor);
        usdc.approve(address(diamond), amountHigth);
        vm.expectRevert(
            abi.encodeWithSelector(
                UnavailableKilos.selector, 1_000_000 * 1e18, amountHigth, amountHigth - 1_000_000 * 1e18
            )
        );
        h.createFuture(investor, address(usdc), amountHigth);
    }
}
