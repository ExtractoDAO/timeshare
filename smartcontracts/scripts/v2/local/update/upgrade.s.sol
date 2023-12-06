// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../../../lib/forge-std/src/Script.sol";
import {Facet, Action} from "../../../../src/extracto/diamond/interfaces/Types.sol";
import {Diamond} from "../../../../src/extracto/diamond/Diamond.sol";
import {NewContract} from "./NewContract.sol";

abstract contract Data is Script {
    bytes32 controllerPrivateKey = hex"ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
    address diamond = address(0x5FC8d32690cc91D4c39d9d3abcBD16989F875707);

    NewContract newContract;
    Facet newFacets;
    Facet[] cut;

    function bytes2uint(bytes32 b) public pure returns (uint256 result) {
        result = uint256(b);
    }

    constructor() {}
}

abstract contract Helper is Data {
    constructor() Data() {}

    function getFacetSelectors() public view returns (bytes4[] memory selectors) {
        selectors = new bytes4[](1);

        selectors[0] = newContract.getYieldFarming.selector;
    }

    function getInitPaylaod() public view returns (bytes memory init) {
        string memory initFunction = "init(address,uint256)";
        init = abi.encodeWithSignature(initFunction, address(1), 100);
    }

    function diamondCut(Facet[] memory _diamondCut, address _init, bytes memory _calldata) public {
        string memory diamondCutFunction = "diamondCut((address,bytes4[],uint8)[],address,bytes)";
        bytes memory payload = abi.encodeWithSignature(diamondCutFunction, _diamondCut, _init, _calldata);

        (bool ok, bytes memory data) = diamond.call(payload);
    }
}

contract Upgrade is Helper {
    constructor() Helper() {}

    function run() external {
        vm.startBroadcast(bytes2uint(controllerPrivateKey));

        newContract = new NewContract();
        newFacets = Facet({facetAddress: address(newContract), action: Action.Modify, fnSelectors: getFacetSelectors()});
        cut.push(newFacets);

        diamondCut(cut, address(0x0), new bytes(0));

        console2.log("NewContract address:   ", address(newContract));
        bytes4[] memory arr = getFacetSelectors();
        console2.log("Functions add:");
        for (uint256 i = 0; i < arr.length; i++) {
            console2.logBytes4(arr[i]);
        }
        console2.log("Diamond address:       ", address(diamond));
        vm.stopBroadcast();
    }
}
