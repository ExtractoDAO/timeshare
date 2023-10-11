// CREDITS: https://github.com/PaulRBerg/prb-math
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./UD60x18.sol" as UD;

/*//////////////////////////////////////////////////////////////////////////
                                CUSTOM TYPE
//////////////////////////////////////////////////////////////////////////*/

// @notice The unsigned 60.18-decimal fixed-point number representation, which can have up to 60 digits and up to 18 decimals.
/// The values of this are bound by the minimum and the maximum values permitted by the Solidity type uint256.
type UD60x18 is uint256;

using {UD.div, UD.mul, UD.sub, UD.add} for UD60x18 global;
