#include "script_component.hpp"
/*
    File: fnc_uiPlace.sqf
    Author: YonV
    Description: Put a control somewhere and show it. Positions are safezone
        fractions - the same numbers ui/pac.inc.hpp is written in.

    Parameters:
        0: The control, or its idc <CONTROL|NUMBER>
        1: x <NUMBER>
        2: y <NUMBER>
        3: w <NUMBER>
        4: h <NUMBER>

    Returns:
        The control <CONTROL>
*/

params ["_ctrl", ["_x", 0, [0]], ["_y", 0, [0]], ["_w", 0, [0]], ["_h", 0, [0]]];

disableSerialization;
if (_ctrl isEqualType 0) then {
    _ctrl = (uiNamespace getVariable [QGVAR(display), displayNull]) displayCtrl _ctrl;
};
if (isNull _ctrl) exitWith {controlNull};

_ctrl ctrlSetPosition [safeZoneX + _x * safeZoneW, safeZoneY + _y * safeZoneH, _w * safeZoneW, _h * safeZoneH];
_ctrl ctrlCommit 0;
_ctrl ctrlShow true;
_ctrl
