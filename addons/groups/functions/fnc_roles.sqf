#include "script_component.hpp"
/*
    File: fnc_roles.sqf
    Author: YonV
    Description: Every role the unit has, {class -> record}, from the same
        place FUNC(role) reads: TAC//PAC's structure when it holds any,
        else the mission's Dynamic_Roles compiled through FUNC(role).

    Parameters:
        None

    Returns:
        HASHMAP - {class -> record}; empty when nothing declares a role
*/

private _pac = (missionNamespace getVariable ["ghostD_pac_structure", createHashMap]) getOrDefault ["roles", createHashMap];
if (_pac isEqualType createHashMap && {count _pac > 0}) exitWith {_pac};

private _out = createHashMap;
{
    private _id = configName _x;
    _out set [_id, [_id] call FUNC(role)];
} forEach ("true" configClasses (missionConfigFile >> "Dynamic_Roles"));

_out
