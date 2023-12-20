// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "../../../token/ERC20.sol";
import {FBase} from "./Future.Base.sol";

contract Future is FBase {
    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        uint256 _weeks,
        address _investor,
        uint256 _locktime,
        uint256 _expirationBlock
    ) FBase(_weeks, _investor, msg.sender, _locktime, _expirationBlock) {}

    /*//////////////////////////////////////////////////////////////
                               FUTURE LOGIC
    //////////////////////////////////////////////////////////////*/

      function lockTimeshare() external returns (bool) {
        onlyInvestor(); // or onyDAO?
        isLocked = true;
        return true;
    }

    function unlockTimeshare() external returns (bool) {
        onlyInvestor(); // or onyDAO?
        isLocked = false;
        return false;
    }

    function sell(uint256 amount) external returns (bytes32) {
        onlyInvestor();

        return sellOrder(amount);
    }

    function swap(address newInvestor) external {
        onlyCommodity();

        investor = newInvestor;
    }
}
