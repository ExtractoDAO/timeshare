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
    bytes32 controllerPrivateKey =
        hex"ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
    bytes32 daoPrivateKey =
        hex"59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d";
    address dao = vm.addr(bytes2uint(daoPrivateKey));
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

    function commodityFacetSelectors()
        public
        view
        returns (bytes4[] memory selectors)
    {
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

    function dexFacetSelectors()
        public
        view
        returns (bytes4[] memory selectors)
    {
        selectors = new bytes4[](5);

        selectors[0] = dex.sellOrders.selector;
        selectors[1] = dex.sellOrder.selector;
        selectors[2] = dex.buyOrders.selector;
        selectors[3] = dex.buyOrder.selector;
        selectors[4] = dex.cancelOrder.selector;
    }
}

contract Local is Helper {
    constructor() Helper() {}

    function run() external {
        // vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        vm.startBroadcast(bytes2uint(controllerPrivateKey));

        usdt = new MockToken("USDT", commoditySupply * 1e18, 18);
        usdc = new MockToken("USDC", commoditySupply * 1e6, 6);
        usdt.transfer(0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 10000 * 1e18);
        usdc.transfer(0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 10000 * 1e18);
        tokens.push(address(usdt));
        decimals.push(18);
        tokens.push(address(usdc));
        decimals.push(6);

        commodity = new Commodity();
        diamond = new Diamond();
        dex = new Dex();
        cow = new COW();
        cow.setDao(address(diamond));

        Facet memory commodityFunctions = Facet({
            facetAddress: address(commodity),
            action: Action.Save,
            fnSelectors: commodityFacetSelectors()
        });

        bytes memory init = abi.encodeWithSelector(
            bytes4(
                keccak256(
                    bytes(
                        "init(address[],uint8[],uint256,uint256,uint256,uint256,uint8,bool,address,address)"
                    )
                )
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

        Facet memory dexFunctions = Facet({
            facetAddress: address(dex),
            action: Action.Save,
            fnSelectors: dexFacetSelectors()
        });
        dexCut.push(dexFunctions);
        diamond.diamondCut(dexCut, address(0x0), new bytes(0));

        console.log("Commodity address: ", address(commodity));
        console.log("Diamond address:   ", address(diamond));
        console.log("USDT address:      ", address(usdt));
        console.log("USDC address:      ", address(usdc));
        console.log("COW address:       ", address(cow));
        console.log("Dex address:       ", address(dex));
        vm.stopBroadcast();
    }
}
