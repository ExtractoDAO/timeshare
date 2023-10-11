// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {COW} from "./COW.sol";

contract COWProxy {
    address immutable owner;
    address[] commodities;
    bool private locked;
    COW cow;

    modifier nonReentrant() {
        require(!locked, "NO_REENTRANCY");
        locked = true;
        _;
        locked = false;
    }

    function isCommodity() internal view {
        bool condition = true;
        for (uint256 i = 0; i < commodities.length; i++) {
            if (commodities[i] == msg.sender) {
                condition = false;
            }
        }
        if (condition) {
            revert("UNAUTHORIZED");
        }
    }

    function onlyOwner() internal view {
        require(msg.sender != address(0x0), "ZERO_ADDRESS");
        require(msg.sender == owner, "UNAUTHORIZED");
    }

    constructor(address startCow) {
        owner = msg.sender;
        cow = COW(startCow);
    }

    function addCommodity(address commodity) external {
        onlyOwner();

        commodities.push(commodity);
    }

    function removeCommodity(address commodity) external {
        onlyOwner();

        uint256 id;
        bool found = false;
        for (uint256 index = 0; index < commodities.length; index++) {
            bool _value = commodities[index] == commodity;
            if (_value) {
                id = index;
                found = true;
                break;
            }
        }
        if (found) {
            commodities[id] = commodities[commodities.length - 1];
            commodities.pop();
        } else {
            require(1 != 1, "COMMODITY_NOT_FOUND");
        }
    }

    function pay(address investor, uint256 amount) public nonReentrant {
        isCommodity();

        cow.pay(investor, amount);
    }
}
