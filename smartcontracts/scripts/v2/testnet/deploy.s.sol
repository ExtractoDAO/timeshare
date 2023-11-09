// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../../lib/forge-std/src/Script.sol";
import {Facet, Action} from "../../../src/extracto/diamond/interfaces/Types.sol";
import {Commodity} from "../../../src/extracto/facet/commodity/v2.0.0/Commodity.sol";
import {Diamond} from "../../../src/extracto/diamond/Diamond.sol";
import {Dex} from "../../../src/extracto/facet/dex/v2.0.0/Dex.sol";
import {MockToken} from "../../../test/MockToken.t.sol";
import {COW} from "../../../src/token/COW.sol";

abstract contract Data is Script {
    bytes32 privateKey = vm.envBytes32("MUMBAI_PRIVATE_KEY");
    address controller = vm.addr(bytes2uint(privateKey));
    // Robson's address
    address dao = address(0x78CAA01F86c42348e847BCEd7e64464B073F3FFf);
    uint256 commodityBuyPrice = 2_00 * 1e16;
    uint256 commoditySellPrice = 2_00 * 1e16;
    uint256 commoditySupply = 1_000_000 * 1e18;
    uint256 locktime = 5;
    uint8 yieldFarming = 50;
    bool activateSells = true;

    address[] tokens;
    uint8[] decimals;

    Commodity commodity;
    Diamond diamond;
    Dex dex;
    COW cow;
    Facet[] commodityCut;
    Facet[] dexCut;
    MockToken usdc;
    MockToken usdt;

    function bytes2uint(bytes32 b) public pure returns (uint256 result) {
        result = uint256(b);
    }

    constructor() {}
}

abstract contract Helper is Data {
    constructor() Data() {}

    function commodityFacetSelectors() public view returns (bytes4[] memory selectors) {
        selectors = new bytes4[](27);

        selectors[0] = commodity.getTotalSupplyKG.selector;
        selectors[1] = commodity.getYieldFarming.selector;
        selectors[2] = commodity.getSellPrice.selector;
        selectors[3] = commodity.getBuyPrice.selector;
        selectors[4] = commodity.getLocktime.selector;
        selectors[5] = commodity.getActivated.selector;
        selectors[6] = commodity.getFullDrawer.selector;
        selectors[7] = commodity.getContractsByInvestor.selector;
        selectors[8] = commodity.getContractByAddress.selector;
        selectors[9] = commodity.getAllowedTokens.selector;
        selectors[10] = commodity.getAllowedTokensLength.selector;
        selectors[11] = commodity.getDao.selector;
        selectors[12] = commodity.getController.selector;
        selectors[13] = commodity.getCOW.selector;
        selectors[14] = commodity.setController.selector;
        selectors[15] = commodity.setDAO.selector;
        selectors[16] = commodity.setCOW.selector;
        selectors[17] = commodity.addTokens.selector;
        selectors[18] = commodity.updateActive.selector;
        selectors[19] = commodity.updateBuyPrice.selector;
        selectors[20] = commodity.updateLockTime.selector;
        selectors[21] = commodity.updateSellPrice.selector;
        selectors[22] = commodity.updateYieldFarming.selector;
        selectors[23] = commodity.delTokens.selector;
        selectors[24] = commodity.init.selector;
        selectors[25] = commodity.createFuture.selector;
        selectors[26] = commodity.mintToken.selector;
    }

    function dexFacetSelectors() public view returns (bytes4[] memory selectors) {
        selectors = new bytes4[](6);

        selectors[0] = dex.sellOrders.selector;
        selectors[1] = dex.sellOrder.selector;
        selectors[2] = dex.buyOrders.selector;
        selectors[3] = dex.buyOrder.selector;
        selectors[4] = dex.cancelOrder.selector;
        selectors[5] = dex.ordersByInvestor.selector;
    }
}

contract Testnet is Helper {
    constructor() Helper() {}

    function run() external {
        vm.startBroadcast(vm.envUint("MUMBAI_PRIVATE_KEY"));

        usdt = new MockToken("ExUSDT", commoditySupply * 1e18, 18);
        tokens.push(address(usdt));
        decimals.push(18);

        commodity = new Commodity();
        diamond = new Diamond();
        dex = new Dex();
        cow = new COW();
        cow.setDao(address(diamond));

        Facet memory commodityFunctions =
            Facet({facetAddress: address(commodity), action: Action.Save, fnSelectors: commodityFacetSelectors()});

        bytes memory init = abi.encodeWithSelector(
            bytes4(
                keccak256(bytes("init(address[],uint8[],uint256,uint256,uint256,uint256,uint8,bool,address,address)"))
            ),
            tokens,
            decimals,
            locktime,
            commoditySupply,
            commodityBuyPrice,
            commoditySellPrice,
            yieldFarming,
            activateSells,
            dao,
            address(cow)
        );
        commodityCut.push(commodityFunctions);
        diamond.diamondCut(commodityCut, address(commodity), init);

        Facet memory dexFunctions =
            Facet({facetAddress: address(dex), action: Action.Save, fnSelectors: dexFacetSelectors()});
        dexCut.push(dexFunctions);
        diamond.diamondCut(dexCut, address(0x0), new bytes(0));

        console.log("Commodity address: ", address(commodity));
        console.log("Diamond address:   ", address(diamond));
        console.log("ExUSDT address:    ", address(usdt));
        console.log("Dex address:       ", address(dex));
        console.log("COW address:       ", address(cow));
        vm.stopBroadcast();
    }
}
