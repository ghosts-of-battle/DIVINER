#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelCombo

Description:
    onLBSelChanged for the rank, role and status combos. A change is sent at
    once - one edit, one write - unless the page is filling, or the value is
    the one the record already has.

Parameters:
    0: Field <STRING> - "rankId" | "groupId" | "roleId" | "statusId"

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
params [["_field", "", [""]]];

if (GVAR(panelFilling)) exitWith {};

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _idc = switch (_field) do {
    case "rankId": {PAC_IDC_RANK_COMBO};
    case "groupId": {PAC_IDC_GROUP_COMBO};
    case "roleId": {PAC_IDC_ROLE_COMBO};
    case "statusId": {PAC_IDC_STATUS_COMBO};
    default {-1};
};
if (_idc < 0) exitWith {};

private _combo = _display displayCtrl _idc;
private _sel = lbCurSel _combo;
if (_sel < 0) exitWith {};

private _id = _combo lbData _sel;
if (_id isEqualTo (GVAR(editRecord) getOrDefault [_field, ""])) exitWith {};

[_field, _id] call FUNC(panelSet);

// A new group means a new role list - the group's slots - with the current
// role kept visible until the admin picks another.
if (_field isEqualTo "groupId") then {
    [_id, GVAR(editRecord) getOrDefault ["roleId", ""]] call FUNC(panelRoleCombo);
};
