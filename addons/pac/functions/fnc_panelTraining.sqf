#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelTraining

Description:
    The TRAINING block on the player page (user, 2026-09-05: "add a
    training section - date, time and notes").

    ADD sends the text; the server stamps it with the time and the admin's
    name. To back-date a course, start the text with the day it was held,
    YYYY-MM-DD, and the server takes that as the date instead:

        2026-08-14 CLS course, passed

    REMOVE takes out the selected row. The rows carry their index into the
    record's own list, so the newest-first display and the stored order
    never disagree about which entry is meant.

Parameters:
    0: Mode <STRING> - "add" | "remove"

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
params [["_mode", "add", [""]]];

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

if (_mode isEqualTo "remove") exitWith {
    private _list = _display displayCtrl PAC_IDC_TRAINING_LIST;
    private _sel = lbCurSel _list;
    if (_sel < 0) exitWith {};
    private _index = parseNumber (_list lbData _sel);
    ["trainingRemove", _index] call FUNC(panelSet);
};

private _edit = _display displayCtrl PAC_IDC_TRAIN_EDIT;
private _text = trim ctrlText _edit;
if (_text isEqualTo "") exitWith {};

if (["trainingAdd", _text] call FUNC(panelSet)) then {
    _edit ctrlSetText "";
};
