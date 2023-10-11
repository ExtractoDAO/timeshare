// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title Diamond Storage Library
/// @dev This library handles the storage and manipulation of facets in a diamond contract.
/// @dev contracts storage in diamond are called facet
/// @dev selectors are a functions of contracts (facets) availables to use in diamond
/// @dev cut are write operations like add/modify/remove facets or selectors of diamond
/// @dev loupe are read operations like get facets or get selectors or get selectors by facets etc... of diamond
/// @dev controller are a dev that have allow to deploy new facets but dont have allow to transfer founds
/// @dev dao is a DAO that receive the founds but dont have allow to deploy new facets
import {Facet, Action} from "../interfaces/Types.sol";
import {
    CannotAddFunctionToDiamondThatAlreadyExists,
    InitializationFunctionReverted,
    CannotRemoveImmutableFunction,
    NoBytecodeAtAddress,
    FacetZeroAddress,
    FunctionNotFound,
    FnSelectorsEmpty,
    IncorrectAction,
    NoAuthorized
} from "../interfaces/Types.sol";

library DiamondStorageLib {
    event DiamondCut(Facet[] _diamondCut, address _init, bytes _calldata);
    event NoInitializationContract();

    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.storage");
    address constant ZERO_ADDRESS = address(0x0);

    /*////////////////////////////////////////////////////////////
                                                           STRUCTS
    ////////////////////////////////////////////////////////////*/

    struct AboutFacet {
        address facet;
        /// @dev index of this fnSelector (key) in the list of selectors for this facet (value).
        uint256 fnSelectorsID;
    }

    struct AboutFnSelectors {
        bytes4[] fnSelectors;
        /// @dev index of the facet (key) that contains these selectors (value) => `address[] facets`
        uint256 facetAddressID;
    }

    struct Storage {
        address controller;
        //
        mapping(bytes4 => AboutFacet) fnSelectorToFacet;
        mapping(address => AboutFnSelectors) facetToFnSelectors;
        // all selectors add in diamond
        bytes4[] fnSelectors;
        uint256 fnSelectorLength;
        // all address of facets add in diamond
        address[] facets;
        uint256 facetsLength;
    }

    /*////////////////////////////////////////////////////////////
                                                    GET FUNCTIONS
    ////////////////////////////////////////////////////////////*/

    /// @notice This function retrieves the diamond storage struct which is declared in a specific storage slot.
    /// @dev The diamond storage struct is stored at a specific storage slot to prevent clashes with other state variables in the contract.
    /// @return lib Returns an instance of the Storage struct (representing the diamond storage).
    function getDiamondStorage() internal pure returns (Storage storage lib) {
        bytes32 storagePosition = DIAMOND_STORAGE_POSITION;
        assembly {
            lib.slot := storagePosition
        }
    }

    function getController() internal view returns (address controller) {
        controller = getDiamondStorage().controller;
    }

    /*////////////////////////////////////////////////////////////
                                                    SET FUNCTIONS
    ////////////////////////////////////////////////////////////*/

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == ZERO_ADDRESS) {
            emit NoInitializationContract();
            return;
        }

        enforceHasContractCode(_init, "function: initializeDiamondCut()");
        (bool success, bytes memory error) = _init.delegatecall(_calldata);

        if (!success) {
            if (error.length > 0) {
                // bubble up error
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(error)
                    revert(add(32, error), returndata_size)
                }
            } else {
                revert InitializationFunctionReverted(_init, _calldata);
            }
        }
    }

    function setController(address newController) internal {
        Storage storage lib = getDiamondStorage();
        lib.controller = newController;
    }

    /*////////////////////////////////////////////////////////////
                                              VALIDATION FUNCTIONS
    ////////////////////////////////////////////////////////////*/

    function onlyController() internal view {
        Storage storage lib = getDiamondStorage();
        if (lib.controller != msg.sender) {
            revert NoAuthorized();
        }
    }

    function enforceHasContractCode(address _contract, string memory debugMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        if (contractSize == 0) {
            revert NoBytecodeAtAddress(_contract, debugMessage);
        }
    }

    /*////////////////////////////////////////////////////////////
                                                     CUT FUCNTIONS
    ////////////////////////////////////////////////////////////*/

    /// @notice This function applies a diamond cut, which is a set of changes to a diamond's facets.
    /// @param _diamondCut An array of facet objects, each containing a facet address, an action (Save, Modify, or Remove), and a list of function selectors.
    /// @param _init The address to use for initialization. If zero, no initialization is performed.
    /// @param _calldata The calldata to use for initialization.
    /// @dev This function emits the `DiamondCut` event.
    /// @dev After the cut has been applied, the diamond is initialized using the `_init` address and `_calldata`.
    /// @dev If the `_init` address is zero, no initialization is performed.
    /// @dev Revert an `IncorrectAction` error if an unknown action type is encountered.
    function diamondCut(Facet[] memory _diamondCut, address _init, bytes memory _calldata) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            Action action = _diamondCut[facetIndex].action;

            if (action == Action.Save) {
                addFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].fnSelectors);
            } else if (action == Action.Modify) {
                replaceFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].fnSelectors);
            } else if (action == Action.Remove) {
                removeFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].fnSelectors);
            } else {
                revert IncorrectAction(uint8(action));
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    /*////////////////////////////////////////////////////////////
                                                    SAVE FUCNTIONS
    ////////////////////////////////////////////////////////////*/

    /// @notice This function is responsible for adding new function selectors to a facet.
    /// @dev It checks:
    /// @dev if the provided function selectors array are not empty.
    /// @dev if the facet address is not zero
    /// @dev if the facet does not already contain the function selectors.
    /// @dev If these conditions are met, the function selectors are added to the facet.
    /// @param _facetAddress The address of the facet to which the function selectors will be added.
    /// @param _fnSelectors An array of function selectors that will be added to the facet.
    function addFunctions(address _facetAddress, bytes4[] memory _fnSelectors) internal {
        checkFacetAddress(_facetAddress, "function: addFunctions()");
        checkFnSelectors(_fnSelectors.length);

        Storage storage lib = getDiamondStorage();

        uint256 fnSelectorsCounter = uint256(lib.facetToFnSelectors[_facetAddress].fnSelectors.length);

        if (fnSelectorsCounter == 0) {
            addFacet(lib, _facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _fnSelectors.length; selectorIndex++) {
            bytes4 selector = _fnSelectors[selectorIndex];
            address oldFacetAddress = lib.fnSelectorToFacet[selector].facet;
            if (oldFacetAddress != ZERO_ADDRESS) {
                revert CannotAddFunctionToDiamondThatAlreadyExists(selector);
            }
            addFunction(lib, selector, fnSelectorsCounter, _facetAddress);
            fnSelectorsCounter++;
        }
    }

    /// @notice This function is responsible for adding a new facet to the contract's storage.
    /// @dev It checks:
    /// @dev if the provided facet address contains bytecode.
    /// @param lib The instance of the contract's storage.
    /// @param _facetAddress The address of the new facet.
    function addFacet(Storage storage lib, address _facetAddress) internal {
        enforceHasContractCode(_facetAddress, "function: addFacet()");

        lib.facetToFnSelectors[_facetAddress].facetAddressID = lib.facets.length;
        lib.facets.push(_facetAddress);
        lib.facetsLength++;
    }

    /// @notice This function is responsible for adding a new function to the contract's storage.
    /// @dev It maps the function selector to the facet and updates the storage.
    /// @param lib The instance of the contract's storage.
    /// @param _selector The function selector that will be added.
    /// @param _selectorPosition The position of the function selector in the list.
    /// @param _facetAddress The address of the facet where the function resides.
    function addFunction(Storage storage lib, bytes4 _selector, uint256 _selectorPosition, address _facetAddress)
        internal
    {
        lib.fnSelectorToFacet[_selector].fnSelectorsID = _selectorPosition;
        lib.facetToFnSelectors[_facetAddress].fnSelectors.push(_selector);
        lib.fnSelectorToFacet[_selector].facet = _facetAddress;
        lib.fnSelectorLength++;
    }

    /*////////////////////////////////////////////////////////////
                                                  MODIFY FUCNTIONS
    ////////////////////////////////////////////////////////////*/

    /// @notice This function replaces a list of function selectors with a new facet address.
    /// @dev It check:
    /// @dev if the provided function selectors array are not empty.
    /// @dev if the facet address is not zero
    /// @dev if the selector is already associated with some facet address
    /// @param _facetAddress The new facet address that the function selectors should be associated with.
    /// @param _fnSelectors The list of function selectors to be replaced.
    function replaceFunctions(address _facetAddress, bytes4[] memory _fnSelectors) internal {
        checkFacetAddress(_facetAddress, "function: replaceFunctions()");
        checkFnSelectors(_fnSelectors.length);

        Storage storage lib = getDiamondStorage();
        uint256 fnSelectorsCounter = uint256(lib.facetToFnSelectors[_facetAddress].fnSelectors.length);
        if (fnSelectorsCounter == 0) {
            addFacet(lib, _facetAddress);
        }

        for (uint256 selectorIndex; selectorIndex < _fnSelectors.length; selectorIndex++) {
            bytes4 selector = _fnSelectors[selectorIndex];
            address oldFacetAddress = lib.fnSelectorToFacet[selector].facet;
            if (oldFacetAddress == _facetAddress) {
                revert CannotAddFunctionToDiamondThatAlreadyExists(selector);
            }
            removeFunction(lib, oldFacetAddress, selector);
            addFunction(lib, selector, fnSelectorsCounter, _facetAddress);
            fnSelectorsCounter++;
        }
    }

    /*////////////////////////////////////////////////////////////
                                                  REMOVE FUCNTIONS
    ////////////////////////////////////////////////////////////*/

    /// @notice This function removes a single function selector from a specific facet address.
    /// @dev It check:
    /// @dev if the provided function selectors array are not empty.
    /// @dev if the facet address is not zero
    /// @dev if facet address is the same address of the diamond
    /// @dev if the facet does not already contain the function selectors.
    /// @dev if a function selector does not exist, it will not throw an error. It will just continue to the next operation.
    /// @param lib A reference to the storage slot where the diamond storage structure resides.
    /// @param _facetAddress The facet address that the function selector should be removed from. This must be a non-zero address and not the address of the current contract.
    /// @param _selector The function selector to be removed.
    function removeFunction(Storage storage lib, address _facetAddress, bytes4 _selector) internal {
        checkFacetAddress(_facetAddress, "function: removeFunction()");

        // replace selector with last selector, then delete last selector
        uint256 selectorPosition = lib.fnSelectorToFacet[_selector].fnSelectorsID;
        uint256 lastSelectorPosition = lib.facetToFnSelectors[_facetAddress].fnSelectors.length - 1;

        // if not the same then replace _selector with lastSelector
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = lib.facetToFnSelectors[_facetAddress].fnSelectors[lastSelectorPosition];
            lib.facetToFnSelectors[_facetAddress].fnSelectors[selectorPosition] = lastSelector;
            lib.fnSelectorToFacet[lastSelector].fnSelectorsID = uint96(selectorPosition);
        }

        // delete the last selector
        lib.facetToFnSelectors[_facetAddress].fnSelectors.pop();
        delete lib.fnSelectorToFacet[_selector];

        // if no more selectors for facet address then delete the facet address
        if (lastSelectorPosition == 0) {
            // replace facet address with last facet address and delete last facet address
            uint256 lastfacetAddressID = lib.facetsLength;
            uint256 facetAddressID = lib.facetToFnSelectors[_facetAddress].facetAddressID;

            if (facetAddressID != lastfacetAddressID) {
                address lastFacetAddress = lib.facets[lastfacetAddressID];
                lib.facets[facetAddressID] = lastFacetAddress;
                lib.facetToFnSelectors[lastFacetAddress].facetAddressID = facetAddressID;
            }

            lib.facets.pop();
            delete lib.facetToFnSelectors[_facetAddress].facetAddressID;
        }
    }

    /// @notice This function removes a batch of functions for a specific facet address.
    /// @dev It check:
    /// @dev if the provided function selectors array are not empty.
    /// @dev if the facet address is not zero
    /// @dev if a function selector does not exist, it will not throw an error. It will just continue to the next function selector.
    /// @param _facetAddress The facet address that the function selectors should be removed from. This must be a non-zero address.
    /// @param _fnSelectors An array of function selectors that are to be removed. This array must not be empty.
    function removeFunctions(address _facetAddress, bytes4[] memory _fnSelectors) internal {
        checkFnSelectors(_fnSelectors.length);
        if (_facetAddress != address(0)) {
            revert FacetZeroAddress(_facetAddress, "function: removeFunctions()");
        }

        Storage storage lib = getDiamondStorage();
        for (uint256 selectorIndex; selectorIndex < _fnSelectors.length; selectorIndex++) {
            bytes4 selector = _fnSelectors[selectorIndex];
            address oldFacetAddress = lib.fnSelectorToFacet[selector].facet;
            removeFunction(lib, oldFacetAddress, selector);
        }
    }

    function checkFnSelectors(uint256 _fnSelectorsLength) internal pure {
        bool fnSelectorsLengthIsZero = _fnSelectorsLength <= 0;

        if (fnSelectorsLengthIsZero) {
            revert FnSelectorsEmpty();
        }
    }

    function checkFacetAddress(address _facetAddress, string memory message) internal view {
        bool facetAddressIsDiamond = _facetAddress == address(this);
        bool facetAddressIsZero = _facetAddress == ZERO_ADDRESS;

        if (facetAddressIsZero) {
            revert FacetZeroAddress(_facetAddress, message);
        } else if (facetAddressIsDiamond) {
            revert CannotRemoveImmutableFunction(_facetAddress);
        }
    }
}
