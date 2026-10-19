#include "script_component.hpp"
/*
    File: fnc_pgOrbatNew.sqf
    Author: YonV
    Description: A new order of battle - a name, and it is written to the
        database as <unit>.orbat.<name> holding what the mission runs now,
        to be made the default and edited from there.

    Parameters:
        None

    Returns:
        Nothing
*/

["New order of battle", "ORBAT  -  Orders of battle"] call FUNC(uiTitle);
private _y = [[["name", "Name  (letters, digits, underscore)", "t", ""]], PAC_UI_TOP] call FUNC(uiForm);
["It starts as a copy of the one the mission runs now. Make it the default on Orders of battle and the next boot reads it; until then its squads and platoons are edited on the website.", _y + 0.006, 0.08, "", PAC_UI_X, PAC_UI_W, true] call FUNC(uiText);

[[
    ["CREATE", {
        private _f = [] call FUNC(uiFormRead);
        private _name = trim (_f getOrDefault ["name", ""]);
        if (_name isEqualTo "" || {(toArray _name) findIf {!(_x isEqualTo 95 || {_x >= 48 && _x <= 57} || {_x >= 65 && _x <= 90} || {_x >= 97 && _x <= 122})} >= 0}) exitWith {["Letters, digits and underscore.", true] call FUNC(uiHint)};
        [player, "newVersion", "set", _name, createHashMap] remoteExec [QFUNC(adminOrbat), 2];
        ["orbat", createHashMapFromArray [["s", "versions"]]] call FUNC(uiGo);
    }]
]] call FUNC(uiButtons);
