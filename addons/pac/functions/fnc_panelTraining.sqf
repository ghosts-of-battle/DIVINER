#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelTraining

Description:
    The TRAINING block on the player page (user, 2026-09-05: "add a
    training section - date, time and notes").

    ADD sends the course picked in the dropdown - the unit's catalogue, the
    "trainings" structure section - with whatever is in the box beside it;
    the server stamps it with the time and the admin's name. To back-date a
    course, start the box with the day it was held, YYYY-MM-DD, and the
    server takes that as the date; the rest of the box is the note:

        2026-08-14 passed

    A unit with no catalogue yet can type the course into the box instead
    (user, 2026-09-05: "a config doc in storage and a drop down to select
    the training").

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

// THE COURSE OFF THE CATALOGUE, the box as its day and note. On a unit that
// keeps no catalogue yet the box alone still works, as free text.
private _combo = _display displayCtrl PAC_IDC_TRAIN_COMBO;
private _sel = lbCurSel _combo;
private _course = if (_sel < 0) then {""} else {_combo lbData _sel};

private _edit = _display displayCtrl PAC_IDC_TRAIN_EDIT;
private _text = trim ctrlText _edit;

if (_course isEqualTo "" && _text isEqualTo "") exitWith {
    ["TAC//PAC", "Pick a course from the list - EDIT STRUCTURE > TRAINING fills it - or type one in the box.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify);
};

private _value = if (_course isEqualTo "") then {_text} else {[_course, _text]};
if (["trainingAdd", _value] call FUNC(panelSet)) then {
    _edit ctrlSetText "";
};
