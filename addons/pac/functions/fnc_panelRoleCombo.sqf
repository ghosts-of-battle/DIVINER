#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelRoleCombo

Description:
    Fills the ROLE combo with the roles of ONE group and selects one. The
    role list is the group's: a squad's slots are its roles, read off
    YMF_dynamicGroups (the same table the group menu draws), each slot's
    Dynamic_Roles class being a PAC role id. With no group chosen every
    role is offered, once each.

    The record's own role is always in the list, even if the group does not
    have that slot - an admin must be able to see what is set before
    changing it.

    Runs under GVAR(panelFilling), because lbSetCurSel fires the combo's
    handler and this is a fill, not a choice.

Parameters:
    0: Group name, "" for all <STRING>
    1: Role id to select, "" for (none) <STRING>

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
params [["_group", "", [""]], ["_roleId", "", [""]]];

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _roles = GVAR(structure) getOrDefault ["roles", createHashMap];
private _ids = [];

if (_group isNotEqualTo "") then {
    {
        _x params ["_name", "_slots"];
        if (toLower _name isEqualTo toLower _group) then {
            {_ids pushBackUnique _x} forEach (_slots select {_x in _roles});
        };
    } forEach (missionNamespace getVariable ["YMF_dynamicGroups", []]);
};
if (_ids isEqualTo []) then {_ids = keys _roles};
if (_roleId isNotEqualTo "" && {!(_roleId in _ids)}) then {_ids pushBack _roleId};

private _rows = _ids apply {[(_roles getOrDefault [_x, createHashMap]) getOrDefault ["name", _x], _x]};
_rows sort true;

private _was = GVAR(panelFilling);
GVAR(panelFilling) = true;

private _combo = _display displayCtrl PAC_IDC_ROLE_COMBO;
lbClear _combo;
_combo lbSetData [_combo lbAdd "(none)", ""];
private _sel = 0;
{
    _x params ["_name", "_id"];
    private _i = _combo lbAdd _name;
    _combo lbSetData [_i, _id];
    if (_id isEqualTo _roleId) then {_sel = _i};
} forEach _rows;
_combo lbSetCurSel _sel;

GVAR(panelFilling) = _was;
