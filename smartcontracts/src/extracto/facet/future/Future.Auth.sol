// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FStorage} from "./Future.Storage.sol";
import "../../../token/ERC20.sol";

error ZeroAddress(address investor);
error BurnContract(address future);
error Locktime(uint256 locktime);
error Unauthorized();

abstract contract FAuth is FStorage {
    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    bool private locked = false;

    constructor(
        uint256 _weeks,
        address _investor,
        address _dao,
        uint256 _locktime,
        uint256 _expirationBlock,
        bool _isLocked
    )
        FStorage(
            _weeks,
            _investor,
            _dao,
            _locktime,
            _expirationBlock,
            _isLocked
        )
    {}
    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier nonReentrant() {
        require(!locked, "NO_REENTRANCY");
        locked = true;
        _;
        locked = false;
    }

    function zeroAddr(address addr) internal pure {
        if (addr == address(0)) {
            revert ZeroAddress(addr);
        }
    }

    function onlyInvestor() internal view {
        zeroAddr(msg.sender);
        if (msg.sender != investor) {
            revert Unauthorized();
        }
    }

    function timeUnlocked() internal view {
        if (block.number < getLockTime) {
            revert Locktime(getLockTime);
        }
    }

    function timeLocked() internal view {
        if(block.number > getLockTime) {
            revert Locktime(getLockTime);
        }
    }

    function burned() internal view {
        if (burn) {
            revert BurnContract(address(this));
        }
    }

    function onlyCommodity() internal view {
        zeroAddr(msg.sender);
        if (msg.sender != dao) {
            revert Unauthorized();
        }
    }
}
