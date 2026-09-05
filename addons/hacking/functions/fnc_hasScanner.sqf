#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_hasScanner

Description:
    Does this unit carry the signal scanner? Pure inventory check against the
    setting, so a mission can point it at a different device without touching
    code.

Parameters:
    _unit : OBJECT - the player.

Returns:
    BOOL

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_unit"];

// NO DEVICE, AND NO REQUIREMENT. Carrying a scanner used to be the gate, and
// for one build it was a flag that defaulted to false - which is the same
// requirement wearing different clothes.
//
// It DEFAULTS TRUE: everyone sweeps unless a mission says otherwise. The
// variable is still read, so setting it false on a unit denies them the
// scanner, which is the only thing a mission is likely to want.
_unit getVariable [GVAR(scannerVariable), true]
