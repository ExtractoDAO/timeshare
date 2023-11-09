// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Commodity} from "../../../src/extracto/facet/commodity/v2.0.0/Commodity.sol";
import {Future} from "../../../src/extracto/facet/future/Future.sol";
import {BaseSetup} from "../../BaseSetup.t.sol";

/*//////////////////////////////////////////////////////////////
        Validate the `locktime` applied by Dao on Future
//////////////////////////////////////////////////////////////*/

contract LockTime is BaseSetup {
    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    /*
    # Scenary: Lock time update dynamic
        - Given: Must receive a timelock
        - When: You have to update the commodity time lock
        - Then: And receive the new timelock
    */
    function test_locktime_dynamic(uint256 startLocktime, uint256 newLocktime) public {
        h.updateLocktime(deployer, startLocktime);

        vm.prank(investor);
        usdc.approve(address(diamond), 10 * 1e18);
        (address _future,) = h.createFuture(investor, address(usdc), 10 * 1e18);

        future = Future(_future);
        assertEq(future.getLockTime(), startLocktime);

        h.updateLocktime(deployer, newLocktime);
        vm.prank(investor);
        usdc.approve(address(diamond), 10 * 1e18);
        (_future,) = h.createFuture(investor, address(usdc), 10 * 1e18);

        future = Future(_future);
        assertEq(future.getLockTime(), newLocktime);
    }
}
