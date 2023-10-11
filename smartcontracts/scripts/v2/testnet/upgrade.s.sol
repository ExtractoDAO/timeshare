// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../../lib/forge-std/src/Script.sol";
import {Facet, Action} from "../../../src/extracto/diamond/interfaces/Types.sol";
import {Diamond} from "../../../src/extracto/diamond/Diamond.sol";
import {CommodityV201} from "../../../src/extracto/facet/commodity/v2.0.1/v2.0.1.Commodity.sol";

abstract contract Data is Script {
    bytes32 privateKey = vm.envBytes32("MUMBAI_PRIVATE_KEY");
    address controller = vm.addr(bytes2uint(privateKey));
    address diamond = address(0xB0932Eee7D34B435429e37B76d4c548dbc42daa7);

    CommodityV201 newContract;
    Action operation;
    Facet newFacets;
    Facet[] cut;

    function bytes2uint(bytes32 b) public pure returns (uint256 result) {
        result = uint256(b);
    }

    constructor() {}
}

abstract contract Helper is Data {
    constructor() Data() {}

    function getFacetSelectors()
        public
        view
        returns (bytes4[] memory selectors)
    {
        selectors = new bytes4[](1);

        selectors[0] = newContract.createFuture.selector;
    }

    function diamondCut(
        Facet[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) public {
        string
            memory diamondCutFunction = "diamondCut((address,bytes4[],uint8)[],address,bytes)";
        bytes memory payload = abi.encodeWithSignature(
            diamondCutFunction,
            _diamondCut,
            _init,
            _calldata
        );

        (bool ok, bytes memory data) = diamond.call(payload);
    }
}

contract Upgrade is Helper {
    constructor() Helper() {}

    function run() external {
        vm.startBroadcast(bytes2uint(controllerPrivateKey));

        // deploy the new contract
        newContract = new CommodityV201();

        // get the selector for new functions deployed on new contract
        operation = Action.Modify;
        newFacets = Facet({
            facetAddress: address(newContract),
            action: operation,
            fnSelectors: getFacetSelectors()
        });
        cut.push(newFacets);

        // add new contract in diamond (cut a new facet of diamond)
        diamondCut(cut, address(0x0), new bytes(0));

        // show results
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
