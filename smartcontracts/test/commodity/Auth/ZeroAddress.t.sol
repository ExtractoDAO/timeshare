// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {
    InvalidToken,
    Unauthorized,
    ZeroAddress,
    UnavailableKilos
} from "../../../src/extracto/facet/commodity/v2.0.0/Commodity.Auth.sol";
import {Future} from "../../../src/extracto/facet/future/Future.sol";
import {BaseSetup} from "../../BaseSetup.t.sol";
import {MockToken} from "../../MockToken.t.sol";

contract TestingZeroAdress is BaseSetup {
    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    /*
    # Scenary: If owner zero address
        - Give: The owner is address zero
        - When: Search the contracts
        - Then: Should return a ZeroAddress error
    */
    function test_if_owner_zero_address_withdraw() public {
        uint256 amount = 485_00 * 1e16; // 485.00 USDC
        address zeroAddress = address(0x0);
        vm.prank(investor);
        usdc.approve(address(diamond), amount);
        (address _future,) = h.createFuture(investor, address(usdc), amount);

        future = Future(_future);
        assertEq(future.investor(), investor);

        vm.prank(zeroAddress);
        vm.expectRevert(abi.encodeWithSelector(ZeroAddress.selector, zeroAddress));
        future.withdraw();
    }

    /*
    # Scenary: a zero address tries to buy a contract but returns Zero Address
        - Give: ZeroAddress tries to buy
        - When: Contract verifies his address
        - Then: Should receive a ZeroAddress error
    */
    function test_buy_zero_address() public {
        uint256 amount = 485_00 * 1e16; // 485.00 USDC
        address zeroaddress = address(0x0);
        vm.prank(zeroaddress);
        usdc.approve(address(diamond), amount);

        vm.expectRevert(abi.encodeWithSelector(ZeroAddress.selector, zeroaddress));
        h.createFuture(zeroaddress, address(usdc), amount);
    }
}
