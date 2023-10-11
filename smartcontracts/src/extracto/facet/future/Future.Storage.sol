// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FEvents} from "./Future.Events.sol";
import {Commodity} from "../commodity/Commodity.sol";

abstract contract FStorage is FEvents {
    /*//////////////////////////////////////////////////////////////
                               STORAGE
    //////////////////////////////////////////////////////////////*/

    Commodity internal immutable extracto;
    uint256 public immutable getLockTime;
    uint256 public immutable getKg;
    address public immutable dao;
    address public investor;
    bool public burn;
    bytes32 orderId;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(uint256 _kg, address _investor, address _dao, uint256 _locktime) {
        require(_investor != address(0x0), "ZERO_ADDRESS");

        getLockTime = block.number + _locktime;
        extracto = Commodity(_dao);
        investor = _investor;
        dao = _dao;
        getKg = _kg;
    }
}
