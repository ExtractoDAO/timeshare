// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {BurnContract} from "../../src/extracto/facet/commodity/v2.0.0/Commodity.Auth.sol";
import {ZeroAddress, Unauthorized, Locktime} from "../../src/extracto/facet/future/Future.Auth.sol";
import {Commodity} from "../../src/extracto/facet/commodity/v2.0.0/Commodity.sol";
import {Future} from "../../src/extracto/facet/future/Future.sol";
import {BaseSetup} from "../BaseSetup.t.sol";

/*//////////////////////////////////////////////////////////////
                Validate the Withdraw of Future
//////////////////////////////////////////////////////////////*/

contract FutureWithdrawTest is BaseSetup {
    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    // Given: that the investor buy 499.23 USDC of Kg of meat
    // AND: that the Yield of the Commodity was 0%
    // When: the contract unlocked
    // then: the new investor should be able to withdraw 261.37 COW

    function test_simple_withdraw() public {
        uint256 amount = 499_23 * 1e16; // 499.23 USDC
        assertEq(cow.balanceOf(investor), 0, "Initial investor balance should be 0");

        vm.prank(investor);
        usdc.approve(address(diamond), amount);
        (address _future,) = h.createFuture(investor, address(usdc), amount);

        future = Future(_future);
        assertEq(future.getKg(), 261_37_696335078534031400, "Incorrect value returned by getKg function");

        vm.roll(locktime + 1);

        vm.prank(investor);
        future.withdraw();

        assertEq(cow.balanceOf(investor), 4992_29_9999999999999997, "Incorrect investor balance after withdrawal");
        assertEq(future.investor(), investor, "Investor address mismatch");
        assertEq(future.dao(), address(diamond), "Incorrect DAO address");
        assertEq(future.burn(), true, "Burn flag not set correctly");
    }

    // Given: that the investor buy 297.12 USDC of Kg of meat
    // AND: that the Yield on the Commodity was 35%.
    // When: the contract unlocked
    // then: the new investor should be able to withdraw 155.56 Kg + 35% Yield == 210.00 COW

    function test_withdraw_with_yield() public {
        vm.prank(investor);
        usdc.approve(address(diamond), 10 * 1e18);
        (address _future,) = h.createFuture(investor, address(usdc), 10 * 1e18);

        future = Future(_future);
        assertEq(future.investor(), investor);
        assertEq(future.getKg(), 5_23_560209424083769600);

        (address _investor,, uint256 _kg,) = h.getContractByAddress(_future);
        assertEq(future.investor(), _investor);
        assertEq(future.getKg(), _kg);

        h.updateYieldFarming(deployer, 35);

        vm.roll(locktime + 1);

        vm.prank(investor);
        future.withdraw();
        assertEq(cow.balanceOf(investor), 134_99_8839999999999993);
    }

    // Given: that the investor buy 324.78 USDC of Kg of meat
    // AND: price move from 3.20 USD/kg to 3.25 USD/kg
    // AND: the new investor has been updated in the Commodity
    // AND: that the Yield on the Commodity was 14.5%.
    // When: the contract unlocked
    // then: the new investor should be able to withdraw  Kg + 35% Yield == 210.00 COW

    function test_withdraw_with_yield_decimals() public {
        vm.prank(investor);
        usdc.approve(address(diamond), 10 * 1e18);
        (address _future,) = h.createFuture(investor, address(usdc), 10 * 1e18);

        future = Future(_future);
        assertEq(future.investor(), investor);
        assertEq(future.getKg(), 5_23_560209424083769600);

        (address _investor,, uint256 _kg,) = h.getContractByAddress(_future);
        assertEq(future.investor(), _investor);
        assertEq(future.getKg(), _kg);

        h.updateYieldFarming(deployer, 35);

        vm.roll(locktime + 1);

        vm.prank(investor);
        future.withdraw();
        assertEq(cow.balanceOf(investor), 134_99_8839999999999993);
    }

    function test_burning_the_same_contract_twice() public {
        uint256 amount = 485_00 * 1e16; // 485.00 USDC
        vm.prank(investor);
        usdc.approve(address(diamond), amount);
        (address _future,) = h.createFuture(investor, address(usdc), amount);

        future = Future(_future);
        assertEq(future.investor(), investor);

        vm.roll(locktime + 1);

        vm.prank(investor);
        future.withdraw();

        vm.prank(investor);
        vm.expectRevert(abi.encodeWithSelector(BurnContract.selector, future));
        future.withdraw();
    }

    function test_withdraw_zeroaddress() public {
        uint256 amount = 485_00 * 1e16; // 485.00 USDC
        vm.prank(investor);
        usdc.approve(address(diamond), amount);
        (address _future,) = h.createFuture(investor, address(usdc), amount);

        future = Future(_future);
        assertEq(future.investor(), investor);

        vm.prank(address(0x000));
        vm.expectRevert(abi.encodeWithSelector(ZeroAddress.selector, address(0x000)));
        future.withdraw();
    }

    function test_withdraw_unauthorized() public {
        uint256 amount = 485_00 * 1e16; // 485.00 USDC
        vm.prank(investor);
        usdc.approve(address(diamond), amount);
        (address _future,) = h.createFuture(investor, address(usdc), amount);

        future = Future(_future);
        assertEq(future.investor(), investor);

        address noOwner = address(0x1234);
        vm.prank(noOwner);
        vm.expectRevert(abi.encodeWithSelector(Unauthorized.selector));
        future.withdraw();
    }

    function test_withdraw_locktime() public {
        uint256 amount = 485_00 * 1e16; // 485.00 USDC
        vm.prank(investor);
        usdc.approve(address(diamond), amount);
        (address _future,) = h.createFuture(investor, address(usdc), amount);

        future = Future(_future);
        assertEq(future.investor(), investor);

        uint256 _locktime = future.getLockTime();
        vm.prank(investor);
        vm.expectRevert(abi.encodeWithSelector(Locktime.selector, _locktime));
        future.withdraw();
    }
}
