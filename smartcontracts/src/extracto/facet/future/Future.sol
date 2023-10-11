// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "../../../token/ERC20.sol";
import {FBase} from "./Future.Base.sol";

contract Future is FBase {
    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(uint256 _kg, address _investor, uint256 _locktime) FBase(_kg, _investor, msg.sender, _locktime) {}

    /*//////////////////////////////////////////////////////////////
                               FUTURE LOGIC
    //////////////////////////////////////////////////////////////*/

    function withdraw() external nonReentrant {
        burned();
        onlyInvestor();
        timeUnlocked();

        _burn();

        emit Withdraw(getKg, investor);

        cancellOrder();
        extracto.mintToken(getKg, investor);
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
