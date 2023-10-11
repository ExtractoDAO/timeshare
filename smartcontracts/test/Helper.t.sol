// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {DexStorageLib} from "../src/extracto/diamond/libraries/Lib.Dex.sol";
import {Diamond} from "../src/extracto/diamond/Diamond.sol";
import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";

contract Helper is Test {
    Diamond diamond;
    bytes payload;
    bytes4 fn;

    constructor(Diamond _diamond) {
        diamond = _diamond;
    }

    function createFuture(address caller, address token, uint256 amount) public returns (address _future, uint256 kg) {
        fn = bytes4(keccak256(bytes("createFuture(address,uint256)")));
        payload = abi.encodeWithSelector(fn, token, amount);

        vm.prank(caller);
        (bool ok, bytes memory data) = address(diamond).call(payload);
        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            (_future, kg) = abi.decode(data, (address, uint256));
        }
    }

    function fullDrawer() public returns (address[] memory futures) {
        fn = bytes4(keccak256(bytes("getFullDrawer()")));
        payload = abi.encodeWithSelector(fn);
        (bool ok, bytes memory data) = address(diamond).call(payload);
        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            futures = abi.decode(data, (address[]));
        }
    }

    function getTokens() public returns (address[] memory tokens) {
        fn = bytes4(keccak256(bytes("getAllowedTokens()")));
        payload = abi.encodeWithSelector(fn);
        (bool ok, bytes memory data) = address(diamond).call(payload);
        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            tokens = abi.decode(data, (address[]));
        }
    }

    function addTokens(address caller, address token, uint8 decimals) external returns (bool) {
        fn = bytes4(keccak256(bytes("addTokens(address,uint8)")));
        payload = abi.encodeWithSelector(fn, token, decimals);

        vm.prank(caller);
        (bool ok, bytes memory data) = address(diamond).call(payload);
        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            return ok;
        }
    }

    function delTokens(address caller, address token) external returns (bool) {
        fn = bytes4(keccak256(bytes("delTokens(address)")));
        payload = abi.encodeWithSelector(fn, token);

        vm.prank(caller);
        (bool ok, bytes memory data) = address(diamond).call(payload);

        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            return ok;
        }
    }

    function updateActive(address caller, bool status) external {
        fn = bytes4(keccak256(bytes("updateActive(bool)")));
        payload = abi.encodeWithSelector(fn, status);

        vm.prank(caller);
        (bool ok, bytes memory data) = address(diamond).call(payload);

        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        }
    }

    function getContractByAddress(address future)
        external
        returns (address investor, address _future, uint256 kg, bool burn)
    {
        fn = bytes4(keccak256(bytes("getContractByAddress(address)")));
        payload = abi.encodeWithSelector(fn, future);

        (bool ok, bytes memory data) = address(diamond).call(payload);

        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            (investor, _future, kg, burn) = abi.decode(data, (address, address, uint256, bool));
        }
    }

    function updateYieldFarming(address caller, uint8 newYield) external {
        fn = bytes4(keccak256(bytes("updateYieldFarming(uint8)")));
        payload = abi.encodeWithSelector(fn, newYield);

        vm.prank(caller);
        (bool ok, bytes memory data) = address(diamond).call(payload);

        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        }
    }

    function updateSellPrice(address caller, uint256 price) external {
        fn = bytes4(keccak256(bytes("updateSellPrice(uint256)")));
        payload = abi.encodeWithSelector(fn, price);

        vm.prank(caller);
        (bool ok, bytes memory data) = address(diamond).call(payload);

        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        }
    }

    function updateBuyPrice(address caller, uint256 price) external {
        fn = bytes4(keccak256(bytes("updateBuyPrice(uint256)")));
        payload = abi.encodeWithSelector(fn, price);

        vm.prank(caller);
        (bool ok, bytes memory data) = address(diamond).call(payload);

        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        }
    }

    function updateLocktime(address caller, uint256 newLoctime) external {
        fn = bytes4(keccak256(bytes("updateLockTime(uint256)")));
        payload = abi.encodeWithSelector(fn, newLoctime);

        vm.prank(caller);
        (bool ok, bytes memory data) = address(diamond).call(payload);

        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        }
    }

    function getActivated() external returns (bool status) {
        fn = bytes4(keccak256(bytes("getActivated()")));
        payload = abi.encodeWithSelector(fn);

        (bool ok, bytes memory data) = address(diamond).call(payload);

        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            status = abi.decode(data, (bool));
        }
    }

    function getTotalSupplyKG() external returns (uint256 supply) {
        fn = bytes4(keccak256(bytes("getTotalSupplyKG()")));
        payload = abi.encodeWithSelector(fn);

        (bool ok, bytes memory data) = address(diamond).call(payload);

        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            supply = abi.decode(data, (uint256));
        }
    }

    function buyOrder(address investor, address token, uint256 commodityAmount, uint256 amount, uint256 randomNonce)
        external
        returns (bytes32 id)
    {
        payload = abi.encodeWithSignature(
            "buyOrder(address,uint256,uint256,uint256)", token, commodityAmount, amount, randomNonce
        );

        vm.prank(investor);
        (bool ok, bytes memory data) = address(diamond).call(payload);

        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            assembly {
                id := mload(add(data, 32))
            }
        }
    }

    function buyOrders() external returns (DexStorageLib.Order[] memory bids) {
        payload = abi.encodeWithSignature("buyOrders()");

        (bool ok, bytes memory data) = address(diamond).call(payload);

        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            bids = abi.decode(data, (DexStorageLib.Order[]));
        }
    }

    function sellOrders() external returns (DexStorageLib.Order[] memory asks) {
        payload = abi.encodeWithSignature("sellOrders()");

        (bool ok, bytes memory data) = address(diamond).call(payload);

        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        } else {
            asks = abi.decode(data, (DexStorageLib.Order[]));
        }
    }

    function cancelOrder(address investor, bytes32 id) external {
        payload = abi.encodeWithSignature("cancelOrder(bytes32)", id);

        vm.prank(investor);
        (bool ok, bytes memory data) = address(diamond).call(payload);

        if (!ok) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        }
    }
}
