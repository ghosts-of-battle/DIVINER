#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelAward

Description:
    ADD gives the player the award picked in the combo, stamped by the server
    with the date and the admin's name. REMOVE takes away the one selected in
    the list above - and every other instance of the same award the player
    has, because the record keys awards by id and a v0 does not need a
    per-instance handle.

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

private _ctrl = _display displayCtrl ([PAC_IDC_AWARD_COMBO, PAC_IDC_AWARDS_LIST] select (_mode isEqualTo "remove"));
private _sel = lbCurSel _ctrl;
if (_sel < 0) exitWith {};

private _id = _ctrl lbData _sel;
if (_id isEqualTo "") exitWith {};

[["awardAdd", "awardRemove"] select (_mode isEqualTo "remove"), _id] call FUNC(panelSet);
