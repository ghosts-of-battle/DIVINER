#include "script_component.hpp"
/*
    File: fnc_uiListClick.sqf
    Author: YonV
    Description: A row in a table was clicked.

        A ROW IS A LINK, as it is on the website: one click, and the page
        the row names opens. The header row (row 0 when the table has one)
        is not a link. The selection is cleared at once and the code runs
        next frame, so a page that redraws the same table from inside its
        own click never draws over a control mid-event.

    Parameters:
        0: The list control <CONTROL>
        1: The row clicked <NUMBER>

    Returns:
        Nothing
*/

params [["_ctrl", controlNull, [controlNull]], ["_row", -1, [0]]];

if (isNull _ctrl || _row < 0) exitWith {};
if (GVAR(uiFilling)) exitWith {};

private _hasHeader = _ctrl getVariable [QGVAR(hasHeader), false];
private _code = _ctrl getVariable [QGVAR(onRow), {}];
private _data = _ctrl lnbData [_row, 0];

GVAR(uiFilling) = true;
_ctrl lnbSetCurSelRow -1;
GVAR(uiFilling) = false;

if (_hasHeader && _row isEqualTo 0) exitWith {};
if (_code isEqualTo {}) exitWith {};

[{
    params ["_code", "_data", "_row"];
    [_data, _row] call _code;
}, [_code, _data, _row]] call CBA_fnc_execNextFrame;
