// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {COW} from "../../../token/COW.sol";
import {NoAuthorized} from "../interfaces/Types.sol";

library DexStorageLib {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.dex.storage");
    address constant ZERO_ADDRESS = address(0x0);

    /*////////////////////////////////////////////////////////////
                                                           STRUCT
    ////////////////////////////////////////////////////////////*/

    enum OrderType {
        Buy, // 1 = buy order
        Sell // 0 = sell order
    }

    struct Order {
        uint256 commodityAmount;
        uint256 amount;
        address tokenAddress;
        address future;
        address investor;
        OrderType typed;
        bytes32 id;
    }

    struct Storage {
        address controller;
        Order[] orderBook;
        mapping(bytes32 => Order) orderById;
        mapping(address => Order[]) ordersByInvestor;
        // v2
        mapping(uint256 amount => mapping(uint256 commodityAmount => Order[] orders)) orderBookMatch;
        mapping(address future => Order order) sellOrdersByAddress;
    }

    /*////////////////////////////////////////////////////////////
                                                    GET FUNCTIONS
    ////////////////////////////////////////////////////////////*/

    /// @notice This function retrieves the diamond storage struct which is declared in a specific storage slot.
    /// @dev The diamond storage struct is stored at a specific storage slot to prevent clashes with other state variables in the contract.
    /// @return lib Returns an instance of the Storage struct (representing the diamond storage).
    function getDexStorage() internal pure returns (Storage storage lib) {
        bytes32 storagePosition = DIAMOND_STORAGE_POSITION;
        assembly {
            lib.slot := storagePosition
        }
    }
}
