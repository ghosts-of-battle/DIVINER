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
// THE WEBSITE'S ORDER, and its wording. Common first - who the unit is - then
// the four in the order they have to be filled in: a squad cannot sit on a net
// that does not exist, and a platoon cannot list a squad that does not.
} forEach [
    ["log", "ACTION LOG"],
    ["faction", "ORBAT - COMMON"],
    ["squads", "ORBAT - SQUADS AND SLOTS"],
    ["squadradio", "ORBAT - SQUAD CHANNELS"],
    ["platoons", "ORBAT - PLATOONS"],
    ["platoonradio", "ORBAT - PLATOON LONG RANGE"],
    ["radionets", "ORBAT - SHARED RADIO NETS"],
    ["operators", "OPERATOR FILES"]
];
_combo lbSetCurSel _sel;     // fires manageSection

[player, "", 400] remoteExec [QFUNC(adminLog), 2];
