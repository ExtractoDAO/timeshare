// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {CommodityStorageLib} from "../../../diamond/libraries/Lib.Commodity.sol";
import {DexStorageLib} from "../../../diamond/libraries/Lib.Dex.sol";
import {ERC20} from "../../../../token/ERC20.sol";

// 0x0eb825b4
error UnavailableKilos(uint256 kilos, uint256 yourAmount, uint256 diff);
// 0x04f3d455
error InsufficientAllowance(uint256 need, uint256 have, uint256 diff);
// 0x6d400e38
error InsufficientAmount(uint256 yourAmount, uint256 minimumAmount);
// 0xcceda04b
error PaymentFailed(address from, address to, uint256 amount);
// 0xc80b8834
error ZeroAddress(address investor);
// 0x961c9a4f
error InvalidToken(address token);
// 0x583fe886
error NoReentrancy();
// 0x1142a68c
error Deactivated();

abstract contract AuthV201 {
    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    bool private locked;

    constructor() {}

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier nonReentrant() {
        if (locked) {
            revert NoReentrancy();
        }
        locked = true;
        _;
        locked = false;
    }

    function zeroAddr(address addr) internal pure {
        if (addr == address(0)) {
            revert ZeroAddress(addr);
        }
    }

    function onlyStableCoins(address token) internal view {
        zeroAddr(token);
        CommodityStorageLib.Storage storage lib = CommodityStorageLib
            .getCommodityStorage();

        for (uint256 i = 0; i < lib.allowedTokensList.length; i++) {
            if (lib.allowedTokensList[i] == token) {
                return;
            }
        }

        revert InvalidToken(token);
    }

    function onlyKgSupply(uint256 amount) internal view {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib
            .getCommodityStorage();

        if (lib.totalCommoditySupply < amount) {
            revert UnavailableKilos(
                lib.totalCommoditySupply,
                amount,
                amount - lib.totalCommoditySupply
            );
        }
    }

    function onlyActive() internal view {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib
            .getCommodityStorage();

        if (lib.activated == false) {
            revert Deactivated();
        }
    }

    function minimumAmount(uint256 amount, address tokenAddress) internal view {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib
            .getCommodityStorage();

        if (amount < 10 * 10 ** lib.allowedTokens[tokenAddress].decimals) {
            revert InsufficientAmount(
                amount,
                10 * 10 ** lib.allowedTokens[tokenAddress].decimals
            );
        }
    }

    function validatePayment(address tokenAddr, uint256 amount) internal {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib
            .getCommodityStorage();
        validateAllowance(tokenAddr, msg.sender, address(this), amount);
        ERC20 token = ERC20(tokenAddr);

        if (token.transferFrom(msg.sender, lib.dao, amount) == false) {
            revert PaymentFailed(msg.sender, lib.dao, amount);
        }
    }

    function validateAllowance(
        address tokenAddr,
        address investor,
        address commodity,
        uint256 amount
    ) internal view {
        ERC20 token = ERC20(tokenAddr);
        uint256 allowance = token.allowance(investor, commodity);

        if (allowance != amount) {
            uint256 need = amount;
            uint256 have = allowance;
            uint256 diff = need - have;
            revert InsufficientAllowance(need, have, diff);
        }
    }
}
