// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "./ERC20.sol";

contract COW is ERC20 {
    address immutable owner;
    address dao;

    constructor() ERC20("Cow", "COW", 18) {
        owner = msg.sender;
    }

    function setDao(address newDao) public {
        require(msg.sender == owner, "UNAUTHORIZED");
        require(msg.sender != address(0x0), "ZERO_ADDRESS");
        require(newDao != address(0x0), "ZERO_ADDRESS");

        dao = newDao;
    }

    function pay(address investor, uint256 amount) public {
        require(msg.sender == dao, "UNAUTHORIZED");
        require(msg.sender != address(0x0), "ZERO_ADDRESS");

        _mint(investor, amount);
    }
}
