// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {CommodityStorageLib} from "../../diamond/libraries/Lib.Commodity.sol";
import {ERC20} from "../../../token/ERC20.sol";
import {Future} from "../future/Future.sol";
import "../../../utils/math/UD60x18.sol";
import {Math} from "./Commodity.Math.sol";

contract Commodity is Math {
    event TokensMinted(uint256 amount, address investor);
    event FutureCreated(address future, address owner, uint256 amount, uint256 locktime);

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() Math() {}

    function init(
        address[] memory tokens,
        uint8[] memory decimals,
        uint256 locktime,
        uint256 commoditySupply,
        uint256 buyPrice,
        uint256 sellPrice,
        uint8 yieldFarming,
        bool active,
        address dao,
        address cow
    ) external returns (bool result) {
        validateTokensDecimalsLength(tokens.length, decimals.length);
        zeroAddr(msg.sender);

        initController(msg.sender);
        setCOW(cow);
        setDAO(dao);

        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        lib.yieldFarming = yieldFarming;
        lib.totalCommoditySupply = commoditySupply;
        lib.sellPrice = sellPrice;
        lib.buyPrice = buyPrice;
        lib.locktime = locktime;
        lib.activated = active;

        for (uint256 i = 0; i < tokens.length; i++) {
            lib.allowedTokens[tokens[i]] = CommodityStorageLib.TokenAndDecimals(i, decimals[i], true);
            lib.allowedTokensList.push(tokens[i]);
        }

        result = true;
    }

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
    function createFuture(address tokenAddress, uint256 amount)
        external
        nonReentrant
        returns (address future, uint256 kg)
    {
        minimumAmount(amount, tokenAddress);
        onlyStableCoins(tokenAddress);
        onlyKgSupply(amount);
        zeroAddr(msg.sender);
        onlyActive();

        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        uint256 blockTarget = calculateBlockTarget(block.number, lib.locktime);

        calculateNewSupply(amount);
        kg = calculateBuyKg(amount, lib.allowedTokens[tokenAddress].decimals);

        Future futureContract = new Future(kg, msg.sender, lib.locktime, blockTarget);
        future = address(futureContract);

        lib.contractsByInvestor[msg.sender].push(CommodityStorageLib.Contract(msg.sender, future, kg, false, blockTarget));
        lib.contracts[future] = CommodityStorageLib.Contract(msg.sender, future, kg, false, blockTarget);
        lib.drawer.push(future);

        validatePayment(tokenAddress, amount);

        emit FutureCreated(future, msg.sender, kg, lib.locktime);
    }

    /**
     * @notice Mints COW tokens for the investor based on a futures contract.
     * @dev 1. onlyFutures: Only a futures contract issued by the Commodity can call this function.
     * @dev 2. The futures contract (msg.sender) will marked as burned.
     * @dev 3. The total number of COW tokens to be sent to the owner of the futures contract is calculated using `calculateSellAmountYielded`.
     * @dev 4. The COW Contract sends the tokens to the investor.
     * @param commodityAmount The amount of commodity used as the basis for calculating the investor's payout.
     * @param investor The address of the owner of the futures contract who will receive the tokens. The tokens will be received by the investor, not by the contract.
     */
    function mintToken(uint256 commodityAmount, address investor) external nonReentrant {
        zeroAddr(investor);
        zeroAddr(msg.sender);
        onlyActive();
        onlyFutures(msg.sender);
        onlyNotBurnedFutures(msg.sender);
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        lib.contracts[msg.sender].burn = true;

        uint256 amount = calculateSellAmountYielded(commodityAmount);

        lib.cow.pay(investor, amount);

        emit TokensMinted(amount, investor);
    }
}
