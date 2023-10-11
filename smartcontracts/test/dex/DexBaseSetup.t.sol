// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Facet, Action} from "../../src/extracto/diamond/interfaces/Types.sol";
import {Dex} from "../../src/extracto/facet/dex/v2.0.0/Dex.sol";
import {BaseSetup} from "../BaseSetup.t.sol";

contract DexBaseSetup is BaseSetup {
    Dex dexFacet;
    Facet[] diamondCutDex;

    function setUp() public virtual override {
        BaseSetup.setUp();

        vm.startPrank(deployer);
        dexFacet = new Dex();

        bytes4[] memory dexSelector = new bytes4[](5);

        dexSelector[0] = dexFacet.sellOrders.selector;
        dexSelector[1] = dexFacet.sellOrder.selector;
        dexSelector[2] = dexFacet.buyOrders.selector;
        dexSelector[3] = dexFacet.buyOrder.selector;
        dexSelector[4] = dexFacet.cancelOrder.selector;

        Facet memory dexFacets = Facet({facetAddress: address(dexFacet), action: Action.Save, fnSelectors: dexSelector});

        diamondCutDex.push(dexFacets);
        diamond.diamondCut(diamondCutDex, address(0x0), new bytes(0));

        vm.stopPrank();
    }
}
