// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {CommodityStorageLib} from "../../diamond/libraries/Lib.Commodity.sol";
import {DexStorageLib} from "../../diamond/libraries/Lib.Dex.sol";
import {ERC20} from "../../../token/ERC20.sol";

// 0xf73354fb
error TokensDecimalsLengthError(uint256 tokensLength, uint256 decimalsLength);
// 0x0eb825b4
error UnavailableKilos(uint256 kilos, uint256 yourAmount, uint256 diff);
// 0x04f3d455
error InsufficientAllowance(uint256 need, uint256 have, uint256 diff);
// 0x6d400e38
error InsufficientAmount(uint256 yourAmount, uint256 minimumAmount);
// 0xcceda04b
error PaymentFailed(address from, address to, uint256 amount);
// 0xe90593d7
error InvalidFutureOwnership(address future, address investor);
// 0xcd54abc4
error InvalidOrderOwnership(address investor, bytes32 orderId);
// 0x778b4c4b
error InvalidYield(uint8 minimum, uint8 maximum);

// 0x5651df57
error FutureNotExists(address future);
// 0xc80b8834
error ZeroAddress(address investor);
// 0x49451944
error BurnContract(address future);
// 0x961c9a4f
error InvalidToken(address token);
// 0x59485ed9
error OrderNotFound(bytes32 id);

// 0x5eea6086
error InvalidCommodityAmount();
// 0x846c2fea
error FutureAlreadyListed();
// 0x8baa579f
error InvalidSignature();
// 0x6e10997a
error SelfTradingError();
// 0x2c5211c6
error InvalidAmount();
// 0xfe835e35
error InternalError();
// 0x82b42900
error Unauthorized();
// 0x583fe886
error NoReentrancy();
// 0x1142a68c
error Deactivated();

abstract contract Auth {
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
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        for (uint256 i = 0; i < lib.allowedTokensList.length; i++) {
            if (lib.allowedTokensList[i] == token) {
                return;
            }
        }

        revert InvalidToken(token);
    }

    function onlyKgSupply(uint256 amount) internal view {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        if (lib.totalCommoditySupply < amount) {
            revert UnavailableKilos(lib.totalCommoditySupply, amount, amount - lib.totalCommoditySupply);
        }
    }

    function onlyActive() internal view {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        if (lib.activated == false) {
            revert Deactivated();
        }
    }

    function revertOrderNotFound(bytes32 id) internal pure {
        revert OrderNotFound(id);
    }

    function revertInternalError() internal pure {
        revert InternalError();
    }

    function minimumAmount(uint256 amount, address tokenAddress) internal view {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        if (amount < 10 * 10 ** lib.allowedTokens[tokenAddress].decimals) {
            revert InsufficientAmount(amount, 10 * 10 ** lib.allowedTokens[tokenAddress].decimals);
        }
    }

    function onlyController() internal view {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        if (lib.controller != msg.sender) {
            revert Unauthorized();
        }
    }

    function validateYield(uint8 newYieldFarming) internal pure {
        // input 1 for yield 1%, if you want to return nothing %, input 0
        if (!(0 <= newYieldFarming && newYieldFarming <= 100)) {
            revert InvalidYield(0, 100);
        }
    }

    function validateTokensDecimalsLength(uint256 tokensLength, uint256 decimalsLength) internal pure {
        if (tokensLength != decimalsLength) {
            revert TokensDecimalsLengthError(tokensLength, decimalsLength);
        }
    }

    function initController(address controller) internal {
        zeroAddr(controller);
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        lib.controller = controller;
    }

    function onlyNotBurnedFutures(address future) internal view {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        if (lib.contracts[future].burn == true) {
            revert BurnContract(future);
        }
    }

    function onlyFutures(address future) internal view {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        if (lib.contracts[future].investor == address(0x0)) {
            revert FutureNotExists(future);
        }
    }

    function onlyOwnerOfFutures(address investor, address future) internal view {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        if (lib.contracts[future].investor != investor) {
            revert InvalidFutureOwnership(future, investor);
        }
    }

    function onlyOwnerOfOrder(address investor, bytes32 id) internal view {
        DexStorageLib.Storage storage lib = DexStorageLib.getDexStorage();

        if (lib.orderById[id].investor != investor) {
            revert InvalidOrderOwnership(investor, id);
        }
    }

    function validatePayment(address tokenAddr, uint256 amount) internal {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        validateAllowance(tokenAddr, msg.sender, address(this), amount);
        ERC20 token = ERC20(tokenAddr);

        if (token.transferFrom(msg.sender, lib.dao, amount) == false) {
            revert PaymentFailed(msg.sender, lib.dao, amount);
        }
    }

    function validatePayment(address tokenAddr, address from, address to, uint256 amount) internal {
        validateAllowance(tokenAddr, from, address(this), amount);
        ERC20 token = ERC20(tokenAddr);

        if (token.transferFrom(from, to, amount) == false) {
            revert PaymentFailed(from, to, amount);
        }
    }

    function validateAllowance(address tokenAddr, address investor, address commodity, uint256 amount) internal view {
        ERC20 token = ERC20(tokenAddr);
        uint256 allowance = token.allowance(investor, commodity);

        if (allowance != amount) {
            uint256 need = amount;
            uint256 have = allowance;
            uint256 diff = need - have;
            revert InsufficientAllowance(need, have, diff);
        }
    }

    function onlyNonListed(address future) internal view {
        DexStorageLib.Storage storage dex = DexStorageLib.getDexStorage();
        if (dex.sellOrdersByAddress[future].investor != address(0x0)) {
            revert FutureAlreadyListed();
        }
    }

    function onlyOtherInvestor(address buyInvestor, address sellInvestor) internal pure {
        if (buyInvestor == sellInvestor) {
            revert SelfTradingError();
        }
    }

    function validateAmounts(uint256 commodityAmount, uint256 amount) internal pure {
        if (amount <= 0) {
            revert InvalidAmount();
        }
        if (commodityAmount <= 0) {
            revert InvalidCommodityAmount();
        }
    }

    function onlyTrueOrder(bytes32 orderId) internal view {
        DexStorageLib.Storage storage lib = DexStorageLib.getDexStorage();
        DexStorageLib.Order memory order = lib.orderById[orderId];

        if (order.investor == address(0x0)) {
            revert OrderNotFound(orderId);
        }
    }
}
