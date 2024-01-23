// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {CommodityStorageLib} from "../../../diamond/libraries/Lib.Commodity.sol";
import {ERC20} from "../../../../token/ERC20.sol";
import {Future} from "../../future/Future.sol";
import "../../../../utils/math/UD60x18.sol";
import {Math} from "./Commodity.Math.sol";

import "forge-std/console.sol";

contract Commodity is Math {
    event TokensMinted(uint256 amount, address investor);
    event FutureCreated(address future, address owner, uint256 amountWeeks, uint256 locktime);

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
        address dao
    ) external returns (bool result) {
        validateTokensDecimalsLength(tokens.length, decimals.length);
        zeroAddr(msg.sender);

        initController(msg.sender);
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
     * @dev 3. The specified amountWeeks of KG must be available in the system.
     * @dev 4. The `msg.sender` must be a VIP investor if Commodity off sales mode is enabled.
     * @dev 5. Calculates the amountWeeks of KG to be minted based on the token amountWeeks and its decimals.
     * @dev 6. Creates a new Future contract with the specified KG and `msg.sender` as the owner.
     * @dev 7. Adds the new Future contract to the list of contracts by investor and drawer.
     * @dev 8. Transfers the specified token amountWeeks from `msg.sender` to the DAO.
     * @param tokenAddress The address of the token to be used to create the Future contract.
     * @param amountWeeks The amountWeeks of tokens to be used to create the Future contract.
     * @return future The address of the newly created Future contract.
     * @return amountWeeks The amountWeeks of KG minted for the new Future contract.
     */
    function createFuture(address tokenAddress, uint256 amount)
        external
        nonReentrant
        returns (address future, uint256 amountWeeks)
    {
        minimumAmount(amount, tokenAddress);
        onlyStableCoins(tokenAddress);
        onlyKgSupply(amount);
        zeroAddr(msg.sender);
        onlyActive();

        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        uint256 expirationBlock = calculateBlockTarget(block.number, lib.locktime);

        calculateNewSupply(amount);
        amountWeeks = calculateBuyKg(amount, lib.allowedTokens[tokenAddress].decimals);

        Future futureContract = new Future(amountWeeks, msg.sender, lib.locktime, expirationBlock, false);
        future = address(futureContract);

        lib.contractsByInvestor[msg.sender].push(CommodityStorageLib.Contract(msg.sender, future, amountWeeks, false, expirationBlock));
        lib.contracts[future] = CommodityStorageLib.Contract(msg.sender, future, amountWeeks, false, expirationBlock);
        lib.drawer.push(future);

        ERC20 token = ERC20(tokenAddress);

        // TODO: !! Precisa verificar o endereço da DAO no contrato LIB. Se será único para cada commodity ou se tem como setar manualmente o mesmo para todos no deploy !!

        uint256 percentageToRecipient = 90;
        console.log("Teste 0");
        uint256 amountToRecipient = calculateAmountToRecipient(amount, percentageToRecipient);
        console.log("Teste 1");
        require(amountToRecipient <= amount, "amountToRecipient insufficient");
        console.log("Teste 2");

        console.log("balanceOf token ====> ", token.balanceOf(address(this)));
        console.log("amountToRecipient ====> ", amountToRecipient);
        require(token.balanceOf(address(this)) >= amountToRecipient, "balanceOf token insufficient ---- to recipient");
        console.log("Teste 3");

        uint256 amountToDAO = calculateAmountToDAO(amount, amountToRecipient);
        console.log("Teste 4");
        require(token.balanceOf(address(this)) >= amountToDAO, "balanceOf token insufficient ---- to DAO");
        console.log("Teste 5");
        validatePayment(tokenAddress, msg.sender, lib.ownerTimeshare, amountToRecipient);
        console.log("Teste 6");
        validatePayment(tokenAddress,msg.sender,lib.dao, amountToDAO);
        console.log("Teste 7");
        emit FutureCreated(future, msg.sender, amountWeeks, lib.locktime);
    }

     function findContractIndex(address investor, address futureAddress) internal view returns (int256) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        CommodityStorageLib.Contract[] storage contracts = lib.contractsByInvestor[investor];

        for (uint256 i = 0; i < contracts.length; i++) {
            if (contracts[i].future == futureAddress) {
                return int256(i);
            }
        }

        return -1; // Contrato não encontrado
    }
}
