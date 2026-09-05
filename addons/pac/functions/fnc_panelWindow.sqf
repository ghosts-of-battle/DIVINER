#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelWindow

Description:
    START and STOP on the admin page. The name comes from the edit beside
    START; the server does the rest (FUNC(windowSet)) and publishes, which
    redraws the status block.

Parameters:
    0: Mode <STRING> - "start" | "stop"

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
params [["_mode", "", [""]]];

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

if (GVAR(summary) getOrDefault ["readOnly", false]) exitWith {
    ["TAC//PAC", "Store is read-only: it was written by a newer PAC.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify);
};

private _edit = _display displayCtrl PAC_IDC_WINDOW_NAME;
private _name = trim ctrlText _edit;

[player, _mode, _name] remoteExec [QFUNC(windowSet), 2];

if (_mode isEqualTo "start") then {_edit ctrlSetText ""};
