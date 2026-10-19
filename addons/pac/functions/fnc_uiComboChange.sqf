#include "script_component.hpp"
/*
    File: fnc_uiComboChange.sqf
    Author: YonV
    Description: A combo on the form changed. Runs the code the page hung on
        it, if any - the form's own reading is done by FUNC(uiFormRead) at
        save time, so most combos have none. Silent while a fill is in
        progress: filling a combo fires this too, and a fill must not write
        back what it just read.

    Parameters:
        0: The combo <CONTROL>
        1: The row selected <NUMBER>

    Returns:
        Nothing
*/

params [["_ctrl", controlNull, [controlNull]], ["_row", -1, [0]]];

if (isNull _ctrl || GVAR(uiFilling)) exitWith {};
private _code = _ctrl getVariable [QGVAR(onChange), {}];
if (_code isEqualTo {}) exitWith {};
[_ctrl, _row, _ctrl lbData _row] call _code;
