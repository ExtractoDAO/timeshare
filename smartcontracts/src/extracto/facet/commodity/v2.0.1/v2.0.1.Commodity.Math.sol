// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {div, ud60x18, unwrap, UD60x18, mul, floor} from "../../../../utils/math/UD60x18.sol";
import {CommodityStorageLib} from "../../../diamond/libraries/Lib.Commodity.sol";
import {UD60x18} from "../../../../utils/math/Type.sol";
import {AuthV201} from "./v2.0.1.Commodity.Auth.sol";

abstract contract MathV201 is AuthV201 {
    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() AuthV201() {}

    /*//////////////////////////////////////////////////////////////
                               BASE LOGIC
    //////////////////////////////////////////////////////////////*/

    function calculateBuyKg(
        uint256 amount,
        uint8 precision
    ) internal view returns (uint256) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib
            .getCommodityStorage();

        // (amount / weightPrice) / precision
        return
            unwrap(
                floor(
                    div(
                        div(ud60x18(amount), ud60x18(lib.buyPrice)),
                        ud60x18(10 ** (precision - 2))
                    )
                )
            );
    }

    function calculateNewSupply(uint256 amount) internal {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib
            .getCommodityStorage();

        // getTotalSupplyKG - amount
        lib.totalCommoditySupply = unwrap(
            ud60x18(lib.totalCommoditySupply).sub(ud60x18(amount))
        );
    }
}
