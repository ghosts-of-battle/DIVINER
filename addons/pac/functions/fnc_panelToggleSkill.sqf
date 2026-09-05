#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelToggleSkill

Description:
    The skills list's onLBSelChanged: a click on a row ticks or unticks that
    skill and sends the whole new list. The row is redrawn at once so a second
    click is on what the admin sees, and the server's answer redraws the lot
    anyway.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
if (GVAR(panelFilling)) exitWith {};
if (count GVAR(editRecord) isEqualTo 0) exitWith {};

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _list = _display displayCtrl PAC_IDC_SKILLS_LIST;
private _sel = lbCurSel _list;
if (_sel < 0) exitWith {};

private _id = _list lbData _sel;
if (_id isEqualTo "") exitWith {};

private _has = +(GVAR(editRecord) getOrDefault ["skillIds", []]);
if (_id in _has) then {
    _has = _has - [_id];
} else {
    _has pushBack _id;
};

GVAR(editRecord) set ["skillIds", _has];
_list lbSetText [_sel, format ["%1  %2", ["[   ]", "[ X ]"] select (_id in _has), ["skills", _id] call FUNC(lookup)]];

["skillIds", _has] call FUNC(panelSet);
