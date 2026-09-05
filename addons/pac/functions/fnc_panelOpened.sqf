#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelOpened

Description:
    Runs from the page's onLoad, after FUNC(panelStyle). Fills the combos from
    the structure once - ranks, roles, statuses, awards, each with a "(none)"
    row whose data is "" - then draws the roster and an empty record.

    Combos are filled here and never again: the structure is compiled config
    and cannot change while the page is open.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
if !([player] call ghostD_adminpanel_fnc_isAdmin) exitWith {closeDialog 2};

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

GVAR(editUid) = "";
GVAR(editRecord) = createHashMap;
GVAR(panelFilling) = true;

private _fnc_fillCombo = {
    params ["_idc", "_section", "_none"];
    private _ctrl = _display displayCtrl _idc;
    lbClear _ctrl;
    if (_none) then {
        _ctrl lbSetData [_ctrl lbAdd "(none)", ""];
    };
    private _rows = [];
    {
        _rows pushBack [_y getOrDefault ["name", _x], _x];
    } forEach (GVAR(structure) getOrDefault [_section, createHashMap]);
    _rows sort true;
    {
        _x params ["_name", "_id"];
        _ctrl lbSetData [_ctrl lbAdd _name, _id];
    } forEach _rows;
};

[PAC_IDC_RANK_COMBO, "ranks", true] call _fnc_fillCombo;
[PAC_IDC_STATUS_COMBO, "statuses", true] call _fnc_fillCombo;

// GROUPS are the group menu's table, not the structure - a squad is a squad
// because the mission set one up. Roster rows that name a group the table
// does not have are offered too, so nothing already written is unreachable.
// ROLES are filled per group by FUNC(panelRoleCombo) when a record opens.
private _groups = (missionNamespace getVariable ["YMF_dynamicGroups", []]) apply {_x # 0};
{
    _x params ["", "", "", "", "_g"];
    if (_g isNotEqualTo "") then {_groups pushBackUnique _g};
} forEach (missionNamespace getVariable [QGVAR(roster), []]);
_groups sort true;
private _gc = _display displayCtrl PAC_IDC_GROUP_COMBO;
lbClear _gc;
_gc lbSetData [_gc lbAdd "(none)", ""];
{_gc lbSetData [_gc lbAdd _x, _x]} forEach _groups;
[PAC_IDC_AWARD_COMBO, "awards", false] call _fnc_fillCombo;

(_display displayCtrl PAC_IDC_HINT) ctrlSetStructuredText parseText "<t size='0.8'><t font='RobotoCondensedBold'>How the op window works.</t> Press START OP as the op begins (a name is optional) and STOP OP when it ends. Everyone on the server in between is counted as attended for that op; the attendance percentage on the operator files comes from these windows. ATTENDANCE TO CLIPBOARD lists who was on and for how long.<br/><br/><t font='RobotoCondensedBold'>The player page.</t> Rank and skills go on the player at once if they are in the field, and on every spawn. What is ticked under SKILLS is what they carry - seeded once from their role, then only this page changes it. Every edit is checked against the admin list on the server and logged with the date.</t>";

GVAR(panelFilling) = false;

[] call FUNC(panelFillRoster);
[] call FUNC(panelFill);
[] call FUNC(panelLog);
[player, "", 40] remoteExec [QFUNC(adminLog), 2];
