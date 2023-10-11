// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

error InvalidYield();
error NoAuthorized();
error ZeroAddress();

/// @dev This error is thrown when the initialization function reverts
/// @param _initializationContractAddress The address of the contract where initialization was attempted
/// @param _calldata The call data that was used for initialization
error InitializationFunctionReverted(address _initializationContractAddress, bytes _calldata);

/// @dev This error is thrown when trying to add a function to the diamond that already exists
/// @param _selector The function selector that is being added
error CannotAddFunctionToDiamondThatAlreadyExists(bytes4 _selector);

/// @dev This error is thrown when a facet address is zero
/// @param facetAddress The facet address that is zero
/// @param debugMessage Additional debug information
error FacetZeroAddress(address facetAddress, string debugMessage);

/// @dev This error is thrown when there is no bytecode at a contract address
/// @param _contract The address of the contract
/// @param debugMessage Additional debug information
error NoBytecodeAtAddress(address _contract, string debugMessage);

/// @dev This error is thrown when trying to remove an immutable function
/// @param facetAddress The address of the facet that contains the immutable function
error CannotRemoveImmutableFunction(address facetAddress);

/// @dev This error is thrown when the function is not found
/// @param fnSelector The selector of the function that was not found
error FunctionNotFound(bytes4 fnSelector);

/// @dev This error is thrown when an action is incorrect
/// @param action The action that is incorrect
error IncorrectAction(uint8 action);

/// @dev This error is thrown when function selectors are empty
error FnSelectorsEmpty();

/// @title Enumeration of possible facet actions
/// @dev Enumeration for defining the action type to be performed on a facet
enum Action {
    Save, // Save the facet
    Modify, // Modify the facet
    Remove // Remove the facet
}

/// @title Structure for Facet
/// @dev Struct for encapsulating a facet in the contract
struct Facet {
    address facetAddress; // The address of the facet
    bytes4[] fnSelectors; // The function selectors associated with the facet
    Action action; // The action to be performed on the facet
}
