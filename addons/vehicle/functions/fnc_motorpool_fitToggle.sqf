#include "script_component.hpp"
/*
    File: fn_motorpool_fitToggle.sqf
    Author: YonV/Ghost
    Description: A fittings row was clicked - flip its ON/OFF state and
        rewrite the row. Selection is then cleared so the same row answers
        a second click (LBSelChanged only fires on change).

    Example:
    [] call ghostD_vehicle_fnc_motorpool_fitToggle;
*/

private _d = uiNamespace getVariable ["YMF_motorpool_dlg", displayNull];
if (isNull _d) exitWith {};

private _lb = _d displayCtrl 166;
private _row = lbCurSel _lb;
if (_row < 0) exitWith {};

private _fits = uiNamespace getVariable ["YMF_motorpool_fits", []];
if (_row >= count _fits) exitWith {_lb lbSetCurSel -1};

private _entry = _fits select _row;
_entry set [2, !(_entry select 2)];

_lb lbSetText [_row, format ["[ %1 ]  %2", ["OFF", "ON"] select (_entry select 2), toUpper (_entry select 0)]];
_lb lbSetCurSel -1;
