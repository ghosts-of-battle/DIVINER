#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelNote

Description:
    ADD NOTE. The server stamps it with the time and the admin's name; the
    page only sends the text.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _edit = _display displayCtrl PAC_IDC_NOTE_EDIT;
private _text = trim ctrlText _edit;
if (_text isEqualTo "") exitWith {};

if (["noteAdd", _text] call FUNC(panelSet)) then {
    _edit ctrlSetText "";
};
