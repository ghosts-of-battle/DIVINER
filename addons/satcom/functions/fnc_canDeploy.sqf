#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_satcom_fnc_canDeploy

Description:
    Is this unit carrying a mast? Pure inventory check, so nothing else has to be
    loaded for the entry to appear.

Parameters:
    _unit : OBJECT - the player.

Returns:
    BOOL

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_unit"];

QGVAR(item) in ((items _unit) + (assignedItems _unit))
