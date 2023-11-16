// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FAuth} from "./Future.Auth.sol";

abstract contract FBase is FAuth {
    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(uint256 _kg, address _investor, address _dao, uint256 _locktime, uint256 _blockTarget)
        FAuth(_kg, _investor, _dao, _locktime, _blockTarget)
    {}

    /*//////////////////////////////////////////////////////////////
                               BASE LOGIC
    //////////////////////////////////////////////////////////////*/

    function _burn() internal {
        burn = true;
    }

    function sellOrder(uint256 amount) internal returns (bytes32 id) {
        timeUnlocked()
        bytes memory payload = abi.encodeWithSignature("sellOrder(address,uint256)", investor, amount);
        (bool ok, bytes memory data) = address(extracto).call(payload);
        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            id = abi.decode(data, (bytes32));
            orderId = id;
        }
    }

    function cancellOrder() internal {
        bytes memory payload = abi.encodeWithSignature("cancelOrder(bytes32)", orderId);
        (bool ok, bytes memory data) = address(extracto).call(payload);
        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        }
    }
}
