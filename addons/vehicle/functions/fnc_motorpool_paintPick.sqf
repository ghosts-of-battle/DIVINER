#include "script_component.hpp"
/*
    File: fn_motorpool_paintPick.sqf
    Author: YonV/Ghost
    Description: A paint row was clicked - mark it as the chosen one and
        rewrite every row so the choice is visible.

        THE ROWS HAD NO HANDLER AT ALL. The vehicle list and the fittings
        list each had one; paint was only ever read at spawn time, off
        lbCurSel. So a press did select the row as far as the engine was
        concerned and the screen said nothing back - the dialog's selection
        colours were authored for the light scheme and all but vanish on
        the dark one, which is what "should be clickable" looks like.

        Paint is one-of-N, so it reads as a dot rather than the fittings'
        ON/OFF: the chosen row carries the mark and the others do not. The
        selection is KEPT here (unlike the fittings, which clear it so the
        same row can be pressed twice) because the spawn reads it.

    Example:
    [] call ghostD_vehicle_fnc_motorpool_paintPick;
*/

private _d = uiNamespace getVariable ["YMF_motorpool_dlg", displayNull];
if (isNull _d) exitWith {};

private _lb = _d displayCtrl 164;
private _row = lbCurSel _lb;
if (_row < 0) exitWith {};

private _paints = uiNamespace getVariable ["YMF_motorpool_paints", []];

// Row 0 is AS DELIVERED - the hull's own paint, which is not in the list.
private _labels = ["AS DELIVERED"] + (_paints apply {toUpper (_x select 0)});

// The same two prefixes fn_motorpool_select writes the list with, so the
// rows do not shift by a space the first time one is pressed.
{
    _lb lbSetText [_forEachIndex, format ["%1%2", ["    ", " >  "] select (_forEachIndex isEqualTo _row), _x]];
} forEach _labels;
