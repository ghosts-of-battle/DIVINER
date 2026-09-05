#include "script_component.hpp"
/*
 * Author: DerZade, mjc4wilton
 * Returns Unit Loadout Array of chestpack of the given unit.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Items <ARRAY>
 *
 * Example:
 * [player] call bocr_main_fnc_chestpackLoadout;
 *
 * Public: No
 */
params ["_unit"];

private _var = _unit getVariable [QGVAR(chestpack), nil];

// Guard before the select - see fnc_chestpackContainer.
if (isNil "_var") exitWith {[]};

private _loadout = +(_var select 2);
if (isNil "_loadout") exitWith {[]};

//return items
_loadout
