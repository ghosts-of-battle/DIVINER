#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A -- Tinkered with by YonV
 * This function adds equipment to a given crate based on group.
 *
 * Arguments:
 * 0: Crate <OBJECT>
 * 1: Group selector <STRING> ["none","reaper","nomad","talon","ghost","wraith","full"]
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [this] call ghostD_logistics_fnc_doStarterCrateSupplies;
 * [this,"reaper"] call ghostD_logistics_fnc_doStarterCrateSupplies;
 *
 */

params [
    ["_crate", objNull, [objNull]],
    ["_groupSelector", "NONE"]
];

if (!isServer) exitWith {};

// Set upper case
_groupSelector = toUpper(_groupSelector);

private _groups = ["REAPER", "NOMAD", "TALON", "GHOST", "WRAITH"];

if !(_groupSelector in (["NONE", "FULL", "ALL"] + _groups)) exitWith {
    ERROR_2("StarterCrate","%1 (Starter Crate Supplies) is using a unsupported cartegory '%2'.",_crate,_groupSelector);
};

INFO_3("StarterCrate","Applying %1 items to %2 (%3)",_groupSelector,_crate,typeOf _crate);

private _container = switch (_groupSelector) do {
    case "REAPER": {GET_CONTAINER("crate_reaper");};
    case "NOMAD": {GET_CONTAINER("crate_nomad");};
    case "TALON": {GET_CONTAINER("crate_talon");};
    case "GHOST": {GET_CONTAINER("crate_ghost");};
    case "WRAITH": {GET_CONTAINER("crate_wraith");};

    case "FULL";
    case "ALL": {
        private _fullContainer = [];
        {
            private _items = GET_CONTAINER(_x);
            _fullContainer append _items;
        } forEach ["crate_reaper", "crate_nomad", "crate_talon", "crate_ghost", "crate_wraith"];
        _fullContainer
    };

    case "";
    case "NONE": {[]};
    default {[]};
};

[_crate, _container] call FUNC(setCargo);

true
