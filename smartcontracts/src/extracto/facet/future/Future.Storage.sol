// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FEvents} from "./Future.Events.sol";
import {Commodity} from "../commodity/v2.0.0/Commodity.sol";

abstract contract FStorage is FEvents {
    /*//////////////////////////////////////////////////////////////
                               STORAGE
    //////////////////////////////////////////////////////////////*/

    Commodity internal immutable extracto;
    uint256 public immutable getLockTime;
    uint256 public immutable getWeeks;
    address public immutable dao;
    address public investor;
    uint256 public expirationBlock;
    bool public isLocked;
    bool public burn;
    bytes32 orderId;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
     constructor(
            uint256 _weeks,
            address _investor,
            address _dao,
            uint256 _locktime,
            uint256 _expirationBlock,
            bool _isLocked
        ) {
        require(_investor != address(0x0), "ZERO_ADDRESS");

        getLockTime = block.number + _locktime;
        extracto = Commodity(_dao);
        investor = _investor;
        dao = _dao;
        getWeeks = _weeks;
        expirationBlock = _expirationBlock;
        isLocked = _isLocked;
    }
}
