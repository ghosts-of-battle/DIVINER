#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelDate

Description:
    SET beside the ENLISTED or PROMOTED date on the admin page: reads the
    edit and sends the date to FUNC(adminSet), which checks it is
    YYYY-MM-DD. Time in service and time in grade are counted from these
    two, so back-dating either is the whole point of the button.

Parameters:
    0: Field <STRING> - "enlistedAt" | "promotedAt"

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
params [["_field", "", [""]]];
if !(_field in ["enlistedAt", "promotedAt"]) exitWith {};

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _text = trim ctrlText (_display displayCtrl ([PAC_IDC_ENLISTED, PAC_IDC_PROMOTED] select (_field isEqualTo "promotedAt")));
if (_text isEqualTo "") exitWith {["TAC//PAC", "Type a date as YYYY-MM-DD first.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify)};

private _digits = (toArray _text) select {_x >= 48 && _x <= 57};
if (count _text isNotEqualTo 10 || count _digits isNotEqualTo 8) exitWith {
    ["TAC//PAC", format ["'%1' is not a date - YYYY-MM-DD, e.g. 2025-03-15.", _text], [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify);
};

[_field, _text] call FUNC(panelSet);
