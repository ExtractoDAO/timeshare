// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {COW} from "../../../token/COW.sol";

library CommodityStorageLib {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.commodity.storage");
    address constant ZERO_ADDRESS = address(0x0);

    struct Contract {
        address investor;
        address future;
        uint256 commodityAmount;
        bool burn;
        uint256 blockTarget;
    }

    struct TokenAndDecimals {
        uint256 index;
        uint8 decimals;
        bool active;
    }

    struct Storage {
        COW cow;
        //
        address controller;
        address dao;
        //
        uint256 totalCommoditySupply;
        uint256 yieldFarming;
        uint256 sellPrice;
        uint256 buyPrice;
        uint256 locktime;
        bool activated;
        //
        address[] allowedTokensList;
        address[] drawer;
        //
        mapping(address => Contract[]) contractsByInvestor;
        mapping(address => TokenAndDecimals) allowedTokens;
        mapping(address => Contract) contracts;
    }

    /// @notice This function retrieves the diamond storage struct which is declared in a specific storage slot.
    /// @dev The diamond storage struct is stored at a specific storage slot to prevent clashes with other state variables in the contract.
    /// @return lib Returns an instance of the Storage struct (representing the diamond storage).
    function getCommodityStorage() internal pure returns (Storage storage lib) {
        bytes32 storagePosition = DIAMOND_STORAGE_POSITION;
        assembly {
            lib.slot := storagePosition
        }
    }
}
