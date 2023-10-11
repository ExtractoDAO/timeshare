# Future ERC

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IFuture {
    event Swapped(uint256 indexed oldInvestor, address indexed newInvestor);
    event Withdraw(uint256 indexed kg, address indexed investor);

    function swap(address newInvestor) external;
    function askOrder(uint256 amount) external;
    function cancelOrder() external;
    function withdraw() external;
}
```


# Future Abstract

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IFuture} from "./Interface.sol";
import {ICommodity} from "../../commodity/ERC/interface.sol";

error Unauthorized(address investor);
error ZeroAddress(address investor);
error BurnContract(address future);
error Locktime(uint256 locktime);

abstract contract Future is IFuture {
    ICommodity internal immutable getCommodity;
    address public immutable getController;
    uint256 public immutable getLockTime;
    uint256 public immutable getKg;
    address public investor;
    bool private locked;
    bool public burn;

    constructor(address controller, address commodity, uint256 locktime, uint256 kg) {
        getController = controller;
        getCommodity = ICommodity(commodity);
        getLockTime = locktime;
        getKg = kg;
    }

    function _burn() internal virtual;

    function swap(address newInvestor) external virtual;

    function askOrder(uint256 amount) external virtual;

    function cancelOrder() external virtual;

    function withdraw() external virtual;

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
            revert Unauthorized(msg.sender);
        }
    }

    function timeUnlocked() internal view {
        if (block.number < getLockTime) {
            revert Locktime(getLockTime - block.number);
        }
    }

    function burned() internal view {
        if (burn) {
            revert BurnContract(address(this));
        }
    }

    function onlyCommodity() internal view {
        zeroAddr(msg.sender);
        if (msg.sender != getController) {
            revert Unauthorized(msg.sender);
        }
    }
}
```