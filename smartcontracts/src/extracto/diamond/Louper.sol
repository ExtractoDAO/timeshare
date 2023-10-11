// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ILouper} from "./interfaces/ILouper.sol";
import {Facet} from "./interfaces/Types.sol";
import {DiamondStorageLib} from "./libraries/Lib.sol";

contract Louper is ILouper {
    function facetAddress(bytes4 fnSelector) external view override returns (address facetAddress_) {
        DiamondStorageLib.Storage storage lib = DiamondStorageLib.getDiamondStorage();

        facetAddress_ = lib.fnSelectorToFacet[fnSelector].facet;
    }

    function facetFunctionSelectors(address facet_) external view override returns (bytes4[] memory fnSelectors) {
        DiamondStorageLib.Storage storage lib = DiamondStorageLib.getDiamondStorage();

        fnSelectors = lib.facetToFnSelectors[facet_].fnSelectors;
    }

    function facetAddresses() external view override returns (address[] memory facetAddresses_) {
        DiamondStorageLib.Storage storage lib = DiamondStorageLib.getDiamondStorage();

        facetAddresses_ = lib.facets;
    }

    function facets() external view override returns (Facet[] memory facets_) {
        DiamondStorageLib.Storage storage lib = DiamondStorageLib.getDiamondStorage();

        uint256 numFacets = lib.facetsLength;
        facets_ = new Facet[](numFacets);

        for (uint256 i; i < numFacets; i++) {
            address facetAddress_ = lib.facets[i];
            facets_[i].facetAddress = facetAddress_;
            facets_[i].fnSelectors = lib.facetToFnSelectors[facetAddress_].fnSelectors;
        }
    }
}
