#include "script_component.hpp"
/*
    File: fnc_uiClick.sqf
    Author: YonV
    Description: Every button in the dialog ends here: it runs the code the
        page hung on the control. A button nobody gave code to does nothing,
        which is what a button with nothing behind it should do.

    Parameters:
        0: The control <CONTROL>

    Returns:
        Nothing
*/

params [["_ctrl", controlNull, [controlNull]]];

if (isNull _ctrl) exitWith {};
private _code = _ctrl getVariable [QGVAR(onClick), {}];
if (_code isEqualTo {}) exitWith {};
[_ctrl] call _code;
