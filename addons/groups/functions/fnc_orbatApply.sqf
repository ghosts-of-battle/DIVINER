#include "script_component.hpp"
/*
    File: fnc_orbatApply.sqf
    Author: YonV
    Description: Rebuilds the live slot table (YMF_dynamicGroups) from the
        ORBAT FUNC(orbat) answers, and broadcasts it. Server only. Called
        by TAC//PAC's boot once its structure is in, because the mission's
        initServer.sqf built the table from Dynamic_Groups before PAC could
        say anything.

        A ROW IS [name, roles, condition, group, units, kind] - the mission's
        initServer.sqf seeds five-element rows from Dynamic_Groups (no kind);
        the sixth is the squad's KIND from the ORBAT (inf, mech_inf, air ...),
        the blue force tracker's icon, read with `param [5, ""]`.

        NOBODY IS THROWN OUT OF A SLOT. A man already seated stays where he
        is by squad name and slot index when the new table has that slot;
        a slot that no longer exists sends him back to the menu. At boot the
        table is empty and this is moot.

    Parameters:
        None

    Returns:
        BOOL - whether the table changed
*/

if (!isServer) exitWith {false};
if (isNil "YMF_dynamicGroups") exitWith {false};

([] call FUNC(orbat)) params ["_groups"];
if (_groups isEqualTo []) exitWith {false};

// same names, same roles, same order - nothing to do
// The KIND (the fourth element, 2026-09-10) is part of what can change: a
// squad turned from infantry to air with nothing else touched still applies.
private _now = YMF_dynamicGroups apply {[_x # 0, _x # 1, _x # 2, _x param [5, ""]]};
private _new = _groups apply {[_x # 0, _x # 1, _x # 2, _x param [3, ""]]};
if (_now isEqualTo _new) exitWith {false};

private _table = [];
{
    _x params ["_name", "_roles", ["_cond", "true"], ["_kind", ""]];
    if !(_kind isEqualType "") then {_kind = ""};
    private _old = YMF_dynamicGroups select {toUpper (_x # 0) isEqualTo toUpper _name};
    private _group = if (_old isEqualTo []) then {grpNull} else {(_old # 0) # 3};
    // A squad that already has its group gets its kind at once - the blue
    // force tracker's icon changes the moment the ORBAT does. A squad with
    // no group yet is stamped when FUNC(assignPlayer) makes one.
    [_group, _kind] call FUNC(groupKind);
    private _units = _roles apply {objNull};
    if (_old isNotEqualTo []) then {
        private _oldUnits = (_old # 0) # 4;
        for "_i" from 0 to ((count _units) - 1) do {
            private _u = _oldUnits param [_i, objNull];
            if (!isNull _u) then {_units set [_i, _u]};
        };
    };
    _table pushBack [_name, +_roles, _cond, _group, _units, _kind];
} forEach _groups;

YMF_dynamicGroups = _table;
[YMF_dynamicGroups] remoteExecCall ["ghostD_groups_fnc_updateGroups", -2, "YMF_DG_JIP"];

INFO_1("Groups","ORBAT applied from the structure: %1 squad(s)",count _table);
true
