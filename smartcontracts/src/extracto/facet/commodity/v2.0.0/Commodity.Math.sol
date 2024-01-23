// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {div, ud60x18, unwrap, UD60x18, mul, add, sub} from "../../../../utils/math/UD60x18.sol";
import {CommodityStorageLib} from "../../../diamond/libraries/Lib.Commodity.sol";
import {UD60x18} from "../../../../utils/math/Type.sol";
import {Crud} from "./Commodity.Crud.sol";

abstract contract Math is Crud {
    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() Crud() {}

    /*//////////////////////////////////////////////////////////////
                               BASE LOGIC
    //////////////////////////////////////////////////////////////*/

    function calculateBuyKg(uint256 amount, uint8 precision) internal view returns (uint256) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        // (amount / weightPrice) / precision
        return unwrap(div(div(ud60x18(amount), ud60x18(lib.buyPrice)), ud60x18(10 ** (precision - 2))));
    }

    function calculateNewSupply(uint256 amount) internal {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        // getTotalSupplyKG - amount
        lib.totalCommoditySupply = unwrap(ud60x18(lib.totalCommoditySupply).sub(ud60x18(amount)));
    }

    function calculateBlockTarget(uint256 currentBlock, uint256 locktime)  internal pure returns (uint256) {
        return unwrap(add(ud60x18(currentBlock), ud60x18(locktime)));
    }

    function calculateAmountToRecipient(uint256 amount, uint256 percentageToRecipient) internal pure returns (uint256) {
        return (
            unwrap(div(mul(ud60x18(amount), ud60x18(percentageToRecipient)), ud60x18(100)))
        );
    }

    function calculateAmountToDAO(uint256 amount, uint256 amountToReceipt) internal pure returns(uint256) {
        return (
            unwrap(sub(ud60x18(amount), ud60x18(amountToReceipt)))
        );
    }

    function calculateSellAmountYielded(uint256 kg) internal view returns (uint256) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        // yieldedKg = (kg * (1 + yieldFarming/100))
        // betterPrecisionYieldKd = yieldedKg / 1^18
        // kgInDolar = betterPrecisionYieldKd * weightPrice
        // kgInCow = kgInDolar / 0.1

        UD60x18 COW_TOKEN_PRICE_IN_DOLAR = div(ud60x18(1), ud60x18(10));
        uint256 BETTER_PRECISION = 1e18;
        uint256 PERCENTAGE = 100;
        return unwrap(
            mul(
                mul(
                    div(
                        div(mul(ud60x18(kg), ud60x18(lib.yieldFarming)), ud60x18(PERCENTAGE)).add(ud60x18(kg)),
                        ud60x18(BETTER_PRECISION)
                    ),
                    ud60x18(lib.sellPrice)
                ),
                COW_TOKEN_PRICE_IN_DOLAR
            )
        );
    }
}
