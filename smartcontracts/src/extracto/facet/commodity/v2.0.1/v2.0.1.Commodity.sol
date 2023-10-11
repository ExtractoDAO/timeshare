// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {CommodityStorageLib} from "../../../diamond/libraries/Lib.Commodity.sol";
import {ERC20} from "../../../../token/ERC20.sol";
import {Future} from "../../future/Future.sol";
import "../../../../utils/math/UD60x18.sol";
import {MathV201} from "./v2.0.1.Commodity.Math.sol";

contract CommodityV201 is MathV201 {
    string public version = "v2.0.1";
    event FutureCreated(
        address future,
        address owner,
        uint256 amount,
        uint256 locktime
    );

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() MathV201() {}

    /*//////////////////////////////////////////////////////////////
                               Commodity LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Creates a new Future contract with the specified parameters.
     * @dev 1. The `msg.sender` must have sufficient balance of the specified token.
     * @dev 2. The specified token must be a stablecoin.
     * @dev 3. The specified amount of KG must be available in the system.
     * @dev 4. The `msg.sender` must be a VIP investor if Commodity off sales mode is enabled.
     * @dev 5. Calculates the amount of KG to be minted based on the token amount and its decimals.
     * @dev 6. Creates a new Future contract with the specified KG and `msg.sender` as the owner.
     * @dev 7. Adds the new Future contract to the list of contracts by investor and drawer.
     * @dev 8. Transfers the specified token amount from `msg.sender` to the DAO.
     * @param tokenAddress The address of the token to be used to create the Future contract.
     * @param amount The amount of tokens to be used to create the Future contract.
     * @return future The address of the newly created Future contract.
     * @return kg The amount of KG minted for the new Future contract.
     */
    function createFuture(
        address tokenAddress,
        uint256 amount
    ) external nonReentrant returns (address future, uint256 kg) {
        minimumAmount(amount, tokenAddress);
        onlyStableCoins(tokenAddress);
        onlyKgSupply(amount);
        zeroAddr(msg.sender);
        onlyActive();

        CommodityStorageLib.Storage storage lib = CommodityStorageLib
            .getCommodityStorage();

        calculateNewSupply(amount);
        kg = calculateBuyKg(amount, lib.allowedTokens[tokenAddress].decimals);

        Future futureContract = new Future(kg, msg.sender, lib.locktime);
        future = address(futureContract);

        lib.contractsByInvestor[msg.sender].push(
            CommodityStorageLib.Contract(msg.sender, future, kg, false)
        );
        lib.contracts[future] = CommodityStorageLib.Contract(
            msg.sender,
            future,
            kg,
            false
        );
        lib.drawer.push(future);

        validatePayment(tokenAddress, amount);

        emit FutureCreated(future, msg.sender, kg, lib.locktime);
    }
}
