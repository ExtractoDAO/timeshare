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

contract OnlyAuthTokensCanUsedToBuy is BaseSetup {
    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    /*
    # Scenary: Token is not VIP
        - Given: that an TOKEN has been removed from TokenWhitelist
        - When: the INVESTOR tries to buy
        - Then: it should revert to "UNAUTHORIZED_TOKEN
    */
    function test_token_is_not_vip() public {
        uint256 amount = 498 * 1e18; // 498.00 NOAUTH
        vm.startPrank(investor);
        MockToken noauth = new MockToken("NOAUTH", amount * 2, 18);

        noauth.approve(address(diamond), amount);
        vm.stopPrank();

        vm.expectRevert(abi.encodeWithSelector(InvalidToken.selector, address(noauth)));
        h.createFuture(investor, address(noauth), amount);
    }

    /*
    # Scenary: TOKEN removed from vip
        - Given: that a TOKEN has been added to the TokenWhitelist
        - And: after he has been removed from the TokenWhitelist
        - When: the INVESTOR tries to buy
        - Then: it should revert to "UNAUTHORIZED_TOKEN
    */
    function test_token_is_removed_from_vip() public {
        uint256 amount = 498 * 1e18; // 498.00 NOAUTH

        vm.prank(investor);
        MockToken noauth = new MockToken("NOAUTH", amount * 2, 18);

        address[] memory _tokens = h.getTokens();
        for (uint256 i = 0; i < _tokens.length; i++) {
            require(_tokens[i] != address(noauth));
        }

        h.addTokens(deployer, address(noauth), 18);
        vm.roll(100);
        h.delTokens(deployer, address(noauth));

        vm.prank(investor);
        noauth.approve(address(diamond), amount);

        vm.expectRevert(abi.encodeWithSelector(InvalidToken.selector, address(noauth)));
        h.createFuture(investor, address(noauth), amount);
    }
}
