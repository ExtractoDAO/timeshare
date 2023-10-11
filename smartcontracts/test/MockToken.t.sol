// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.16;

import {ERC20} from "../src/token/ERC20.sol";

contract MockToken is ERC20 {
    constructor(string memory _symbol, uint256 initialSupply, uint8 _decimals) ERC20("", _symbol, _decimals) {
        _mint(msg.sender, initialSupply);
    }
}
