#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_manageOpened

Description:
    onLoad of the management window: fills the section combo, shows the
    section that was open last (the log the first time) and asks the
    server for the log.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
if !([player] call ghostD_adminpanel_fnc_isAdmin) exitWith {closeDialog 2};

private _display = uiNamespace getVariable [QGVAR(manageDisplay), displayNull];
if (isNull _display) exitWith {};

private _combo = _display displayCtrl PAC_IDC_MG_SECTION;
lbClear _combo;
private _sel = 0;
{
    _x params ["_id", "_label"];
    private _i = _combo lbAdd _label;
    _combo lbSetData [_i, _id];
    if (_id isEqualTo GVAR(mgSection)) then {_sel = _i};
} forEach [
    ["log", "ACTION LOG"],
    ["squads", "ORBAT - SQUADS AND SLOTS"],
    ["platoons", "ORBAT - PLATOON TABS"],
    ["radionets", "ORBAT - SHARED RADIO NETS"],
    ["faction", "ORBAT - FACTION"],
    ["operators", "OPERATOR FILES"]
];
_combo lbSetCurSel _sel;     // fires manageSection

[player, "", 400] remoteExec [QFUNC(adminLog), 2];
