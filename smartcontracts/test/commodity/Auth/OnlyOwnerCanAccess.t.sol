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

contract OnlyOwnerCanAccess is BaseSetup {
    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    /*
    # Scenary: Only OWNER can activate sales
        - Give: any user cant activate sales
        - When: any user tries
        - Then: should revert to "NO_OWNER"
    */
    function test_only_owner_can_activate_sales(address nonOwner) public {
        vm.assume(nonOwner != address(0x0));

        vm.expectRevert(abi.encodeWithSelector(Unauthorized.selector));
        h.updateActive(nonOwner, false);
    }

    /*
    # Scenary: Address not owner of the contract tries to withdraw
        - Give: Non-owner of the contract tries to cash out
        - When: since the contract is already available to withdraw
        - Then: Should return Unauthorized error to non-owner
    */
    function test_Address_not_owner_of_the_contract_tries_to_withdraw(address noOwner) public {
        uint256 amount = 485_00 * 1e16; // 485.00 USDC
        vm.assume(noOwner != address(0x0) && noOwner != investor);

        vm.prank(investor);
        usdc.approve(address(diamond), amount);
        (address _future,) = h.createFuture(investor, address(usdc), amount);

        future = Future(_future);
        assertEq(future.investor(), investor);

        vm.prank(noOwner);
        vm.expectRevert(abi.encodeWithSelector(Unauthorized.selector));
        future.withdraw();
    }
}
