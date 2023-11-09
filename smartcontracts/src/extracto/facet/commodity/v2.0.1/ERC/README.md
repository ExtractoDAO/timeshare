# Commodity ERC

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

struct Ask {
    uint256 commodityAmount;
    address future;
    address owner;
    uint256 value;
}

struct Bid {
    uint256 commodityAmount;
    address tokenAddress;
    address owner;
    uint256 value;
}

struct Contract {
    address investor;
    address future;
    uint256 kg;
    bool burn;
}

struct TokenMetadata {
    uint256 index;
    uint8 decimals;
    bool active;
}

struct Vip {
    uint256 index;
    bool active;
}

interface ICommodity {
    ///////////////////////////////////////////////////////////////
    /// COMMODITY LOGIC
    ///////////////////////////////////////////////////////////////

    function createFuture(address tokenAddress, uint256 amount) external returns (address, uint256);
    function settleContract(uint256 kg, address investor) external;

    ///////////////////////////////////////////////////////////////
    /// COMMODITY DEX
    ///////////////////////////////////////////////////////////////

    function buyOrder(address tokenAddress, uint256 commodityAmount, uint256 value) external;
    function sellOrder(address ownerOrder, uint256 commodityAmount, uint256 value) external;
    function cancelOrder(bool orderType, uint256 value, uint256 commodityAmount) external;

    ///////////////////////////////////////////////////////////////
    /// COMMODITY ADD DATA
    ///////////////////////////////////////////////////////////////

    function addTokens(address newToken, uint8 decimal) external;
    function addAddressWhitelist(address newVip) external;

    ///////////////////////////////////////////////////////////////
    /// COMMODITY GET DATA
    ///////////////////////////////////////////////////////////////

    function getContractsByInvestor(address investor) external view returns (Contract[] memory);
    function getFullDrawer() external view returns (address[] memory);
    function getWhiteList() external view returns (address[] memory);
    function getTokens() external view returns (address[] memory);
    function allAskOrders() external view returns (Ask[] memory);
    function allBidOrders() external view returns (Bid[] memory);

    ///////////////////////////////////////////////////////////////
    /// COMMODITY UPDATE DATA
    ///////////////////////////////////////////////////////////////

    function updateYieldFarming(uint256 newYieldFarming) external;
    function updateSellPrice(uint256 newSellPrice) external;
    function updateBuyPrice(uint256 newBuyPrice) external;
    function updateLockTime(uint256 newLockTime) external;
    function updateActive(bool state) external;

    ///////////////////////////////////////////////////////////////
    /// COMMODITY DELETE DATA
    ///////////////////////////////////////////////////////////////

    function delAddressWhitelist(address novip) external;
    function delTokens(address noauth) external;
}
```

# Commodity Abstract

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ICommodity, Contract, Ask, Bid, Vip, TokenMetadata} from "./interface.sol";
import {COW} from "../../../token/COW.sol";

abstract contract Commodity is ICommodity {
    ///////////////////////////////////////////////////////////////
    /// COMMODITY STORAGE
    ///////////////////////////////////////////////////////////////
    COW immutable cow;

    uint256 public getTotalSupplyKG;
    uint256 public getYieldFarming;
    address public immutable owner;
    address public immutable controller;
    uint256 public getSellPrice;
    uint256 public getBuyPrice;
    uint256 public getLockTime;
    bool public getActivated;
    bool public locked;

    address[] internal tokens;
    address[] public drawer;
    address[] internal vips;
    Ask[] public askOrders;
    Bid[] public bidOrders;

    mapping(address => Contract[]) internal contractsByInvestor;
    mapping(address => TokenMetadata) internal tokenList;
    mapping(address => Contract) public getContract;
    mapping(address => Vip) internal whitelist;
    mapping(uint256 => Ask) askOrderById;
    mapping(uint256 => Bid) bidOrderById;

    ///////////////////////////////////////////////////////////////
    /// COMMODITY ERRORS
    ///////////////////////////////////////////////////////////////

    error InvalidOwnership(address future, address investor);
    error WithoutWhitelist(address investor);
    error UnavailableKilos(uint256 kilos);
    error Unauthorized(address investor);
    error ZeroAddress(address investor);
    error BurnContract(address future);
    error InvalidToken(address token);
    error OrderNotFound();

    ///////////////////////////////////////////////////////////////
    /// COMMODITY AUTHENTICATION
    ///////////////////////////////////////////////////////////////

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

    function onlyOwner() internal view {
        zeroAddr(msg.sender);
        if (msg.sender != owner) {
            revert Unauthorized(msg.sender);
        }
    }

    function onlyFutures(address investor, address future) internal view {
        zeroAddr(getContract[future].investor);
        zeroAddr(msg.sender);
        zeroAddr(investor);
        zeroAddr(future);

        if (getContract[future].burn == true) {
            revert BurnContract(future);
        }
        if (getContract[future].investor != investor) {
            revert InvalidOwnership(future, investor);
        }
    }

    function onlyStableCoins(address token) internal view {
        zeroAddr(token);

        bool condition = true;
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == token) {
                condition = false;
            }
        }
        if (condition) {
            revert InvalidToken(token);
        }
    }

    function onlyKgSupply(uint256 amount) internal view {
        if (getTotalSupplyKG <= amount) {
            revert UnavailableKilos(getTotalSupplyKG);
        }
    }

    function onlyActive(address investor) internal view {
        zeroAddr(investor);

        if (getActivated == false) {
            if (whitelist[investor].active == false) {
                revert WithoutWhitelist(investor);
            }
        }
    }

    function revertOrderNotFound() internal pure {
        revert OrderNotFound();
    }

    ///////////////////////////////////////////////////////////////
    /// COMMODITY MATHEMATICAL
    ///////////////////////////////////////////////////////////////

    // (amount / weightPrice) / precision
    function calculateBuyKg(uint256 amount, uint8 precision) internal view virtual returns (uint256);

    // getTotalSupplyKG - amount
    function calculateNewSupply(uint256 amount) internal virtual;

    // yieldedKg = (kg * (1 + yieldFarming/100))
    // betterPrecisionYieldKd = yieldedKg / 1^18
    // kgInDolar = betterPrecisionYieldKd * weightPrice
    // kgInCow = kgInDolar / 0.1
    function calculateSellAmountYielded(uint256 kg) internal view virtual returns (uint256);

    ///////////////////////////////////////////////////////////////
    /// COMMODITY EVENTS
    ///////////////////////////////////////////////////////////////

    event FutureCreated(address indexed future, uint256 indexed amount, address indexed investor, uint256 locktime);
    event SettledContract(address future, uint256 indexed amount, address indexed investor);

    ///////////////////////////////////////////////////////////////
    /// COMMODITY LOGIC
    ///////////////////////////////////////////////////////////////

    function createFuture(address tokenAddress, uint256 amount) external virtual returns (address, uint256);
    function settleContract(uint256 kg, address investor) external virtual;

    ///////////////////////////////////////////////////////////////
    /// COMMODITY DEX
    ///////////////////////////////////////////////////////////////

    function buyOrder(address tokenAddress, uint256 commodityAmount, uint256 value) external virtual;
    function sellOrder(address ownerOrder, uint256 commodityAmount, uint256 value) external virtual;
    function cancelOrder(bool orderType, uint256 value, uint256 commodityAmount) external virtual;

    ///////////////////////////////////////////////////////////////
    /// COMMODITY ADD DATA
    ///////////////////////////////////////////////////////////////

    function addTokens(address newToken, uint8 decimal) external virtual;
    function addAddressWhitelist(address newVip) external virtual;

    ///////////////////////////////////////////////////////////////
    /// COMMODITY GET DATA
    ///////////////////////////////////////////////////////////////

    function getContractsByInvestor(address investor) external view virtual returns (Contract[] memory);
    function getFullDrawer() external view virtual returns (address[] memory);
    function getWhiteList() external view virtual returns (address[] memory);
    function getTokens() external view virtual returns (address[] memory);
    function allAskOrders() external view virtual returns (Ask[] memory);
    function allBidOrders() external view virtual returns (Bid[] memory);

    ///////////////////////////////////////////////////////////////
    /// COMMODITY UPDATE DATA
    ///////////////////////////////////////////////////////////////

    function updateYieldFarming(uint256 newYieldFarming) external virtual;
    function updateSellPrice(uint256 newSellPrice) external virtual;
    function updateBuyPrice(uint256 newBuyPrice) external virtual;
    function updateLockTime(uint256 newLockTime) external virtual;
    function updateActive(bool state) external virtual;

    ///////////////////////////////////////////////////////////////
    /// COMMODITY DELETE DATA
    ///////////////////////////////////////////////////////////////

    function delAddressWhitelist(address novip) external virtual;
    function delTokens(address noauth) external virtual;

    ///////////////////////////////////////////////////////////////
    /// COMMODITY CONSTRUCTOR
    ///////////////////////////////////////////////////////////////

    constructor(
        address[] memory _tokens,
        uint8[] memory decimals,
        uint256 _lockTime,
        uint256 _kgSupply,
        uint256 _buyPrice,
        uint256 _sellPrice,
        address _controller,
        address _cow,
        bool _active
    ) {
        require(_tokens.length == decimals.length, "TOKENS_DECIMALS_LENGTH_ERROR");
        require(msg.sender != address(0x0), "ZERO_ADDRESS");
        getTotalSupplyKG = _kgSupply;
        getSellPrice = _sellPrice;
        getBuyPrice = _buyPrice;
        getLockTime = _lockTime;
        getActivated = _active;
        owner = msg.sender;
        cow = COW(_cow);
        controller = _controller;

        for (uint256 i = 0; i < _tokens.length; i++) {
            tokenList[_tokens[i]] = TokenMetadata(i, decimals[i], true);
            tokens.push(_tokens[i]);
        }
    }
}
```
