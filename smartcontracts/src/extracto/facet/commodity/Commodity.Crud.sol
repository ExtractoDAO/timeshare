// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {CommodityStorageLib} from "../../diamond/libraries/Lib.Commodity.sol";
import {COW} from "../../../token/COW.sol";
import {Auth} from "./Commodity.Auth.sol";

abstract contract Crud is Auth {
    constructor() Auth() {}

    /*////////////////////////////////////////////////////////////
                                                    GET FUNCTIONS
    ////////////////////////////////////////////////////////////*/

    function getTotalSupplyKG() public view returns (uint256 totalSupplyKg) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        totalSupplyKg = lib.totalCommoditySupply;
    }

    function getYieldFarming() public view returns (uint256 yieldFarming) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        yieldFarming = lib.yieldFarming;
    }

    function getSellPrice() public view returns (uint256 sellPrice) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        sellPrice = lib.sellPrice;
    }

    function getBuyPrice() public view returns (uint256 buyPrice) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        buyPrice = lib.buyPrice;
    }

    function getLocktime() public view returns (uint256 locktime) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        locktime = lib.locktime;
    }

    function getActivated() public view returns (bool activated) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        activated = lib.activated;
    }

    function getFullDrawer() external view returns (address[] memory drawer) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        drawer = lib.drawer;
    }

    function getContractsByInvestor(address investor)
        public
        view
        returns (CommodityStorageLib.Contract[] memory contractsInvestor)
    {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        contractsInvestor = lib.contractsByInvestor[investor];
    }

    function getContractByAddress(address future)
        public
        view
        returns (address investor, address _future, uint256 kg, bool burn, uint256 blockTarget)
    {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        CommodityStorageLib.Contract memory _contract = lib.contracts[future];

        investor = _contract.investor;
        _future = _contract.future;
        kg = _contract.commodityAmount;
        burn = _contract.burn;
        blockTarget = _contract.blockTarget;
    }

    function getAllowedTokens() public view returns (address[] memory tokens) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        tokens = lib.allowedTokensList;
    }

    function getAllowedTokensLength() public view returns (uint256 length) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        length = lib.allowedTokensList.length;
    }

    function getDao() public view returns (address dao) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        dao = lib.dao;
    }

    function getController() public view returns (address controller) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        controller = lib.controller;
    }

    function getCOW() public view returns (COW cow) {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        cow = lib.cow;
    }

    /*////////////////////////////////////////////////////////////
                                                    SET FUNCTIONS
    ////////////////////////////////////////////////////////////*/

    // TODO: add multisig
    function setController(address newController) public {
        onlyController();
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        lib.controller = newController;
    }

    // TODO: add multisig
    function setDAO(address newDAO) public {
        onlyController();
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        lib.dao = newDAO;
    }

    function setCOW(address newCow) public {
        onlyController();
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        lib.cow = COW(newCow);
    }

    /*//////////////////////////////////////////////////////////////
                                ADD
    //////////////////////////////////////////////////////////////*/

    function addTokens(address newToken, uint8 decimal) public {
        onlyController();
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        CommodityStorageLib.TokenAndDecimals memory token =
            CommodityStorageLib.TokenAndDecimals(getAllowedTokensLength(), decimal, true);
        lib.allowedTokens[newToken] = token;
        lib.allowedTokensList.push(newToken);
    }

    /*//////////////////////////////////////////////////////////////
                                UPDATE
    //////////////////////////////////////////////////////////////*/

    function updateActive(bool state) public {
        onlyController();
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        lib.activated = state;
    }

    function updateBuyPrice(uint256 newBuyPrice) public {
        onlyController();
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        lib.buyPrice = newBuyPrice;
    }

    function updateLockTime(uint256 newLockTime) public {
        onlyController();
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        lib.locktime = newLockTime;
    }

    function updateSellPrice(uint256 newSellPrice) public {
        onlyController();
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        lib.sellPrice = newSellPrice;
    }

    function updateYieldFarming(uint8 newYieldFarming) public {
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();
        onlyController();
        validateYield(newYieldFarming);

        lib.yieldFarming = newYieldFarming;
    }

    /*//////////////////////////////////////////////////////////////
                                DELETE
    //////////////////////////////////////////////////////////////*/

    function delTokens(address noauth) public {
        onlyController();
        CommodityStorageLib.Storage storage lib = CommodityStorageLib.getCommodityStorage();

        lib.allowedTokens[noauth].active = false;
        lib.allowedTokensList[lib.allowedTokens[noauth].index] = lib.allowedTokensList[lib.allowedTokensList.length - 1];
        lib.allowedTokensList.pop();
    }
}
