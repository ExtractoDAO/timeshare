// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Commodity} from "../../../src/extracto/facet/commodity/v2.0.0/Commodity.sol";
import {Future} from "../../../src/extracto/facet/future/Future.sol";
import {BaseSetup} from "../../BaseSetup.t.sol";
import {MockToken} from "../../MockToken.t.sol";

/*//////////////////////////////////////////////////////////////
            Testing `pucharses` with different tokens
//////////////////////////////////////////////////////////////*/

contract StableCoinsFuture is BaseSetup {
    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    /*
    # Scenary: Buy futures with USDC
     - Given: the investor want buy 498.00 `USDC` of Kg meat
     - When: the investor give approve for Dao
     - AND: buy Future contract
     - Then: the Dao receive 498.00 USDC
     - AND: a new Future contract is created
     - AND: this contract have Kg that should be 260.73 kg
     - AND: this contract should be locked at block number 6,415,200
     - AND: this contract have an owner that should be investor address
     - AND: this contract should have sale deactivated
     - AND: this contract have emissor that should be Dao address
     - AND: this contract have price that should be 0
    */
    function test_buy_Futures_with_USDC() public {
        uint256 amount = 498 * 1e18; // 498.00 USDC

        uint256 balanceBeforeInvestor = usdc.balanceOf(investor);
        uint256 balanceBeforeDao = usdc.balanceOf(controller);

        vm.prank(investor);
        usdc.approve(address(diamond), amount);
        (address _future,) = h.createFuture(investor, address(usdc), amount);

        assertEq(balanceBeforeInvestor - amount, usdc.balanceOf(investor));
        assertEq(balanceBeforeDao + amount, usdc.balanceOf(controller));

        future = Future(_future);

        assertEq(future.getLockTime(), locktime);
        assertEq(future.investor(), investor);
        assertEq(future.dao(), address(diamond));
        assertEq(
            future.getKg(),
            // 260.73 kg
            260_73_298429319371727700
        );
    }

    function test_buy_Futures_with_new_token() public {
        uint256 amount = 498 * 1e18; // 498.00 USDC
        vm.prank(investor);
        MockToken newToken = new MockToken("NEWTOKEN", amount * 2, 18);
        h.addTokens(deployer, address(newToken), 18);

        uint256 balanceBeforeInvestor = newToken.balanceOf(investor);
        uint256 balanceBeforeDao = newToken.balanceOf(controller);

        vm.prank(investor);
        newToken.approve(address(diamond), amount);
        (address _future,) = h.createFuture(investor, address(newToken), amount);

        assertEq(balanceBeforeInvestor - amount, newToken.balanceOf(investor));
        assertEq(balanceBeforeDao + amount, newToken.balanceOf(controller));

        future = Future(_future);

        assertEq(future.getLockTime(), locktime);
        assertEq(future.investor(), investor);
        assertEq(future.dao(), address(diamond));
        assertEq(
            future.getKg(),
            // 260.73 kg
            260_73_298429319371727700
        );
    }
}
