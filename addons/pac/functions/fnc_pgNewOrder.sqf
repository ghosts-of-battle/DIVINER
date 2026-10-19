#include "script_component.hpp"
/*
    File: fnc_pgNewOrder.sqf
    Author: YonV
    Description: Start a new operation order - id and title, then straight
        into writing it.

    Parameters:
        None

    Returns:
        Nothing
*/

["Start a new order", "Operation orders"] call FUNC(uiTitle);
private _y = [[
    ["id", "Id  (a-z 0-9 _)", "t", ""],
    ["title", "Title", "t", ""]
], PAC_UI_TOP] call FUNC(uiForm);
["op_ironveil / OPERATION IRON VEIL. Which order the mission runs is settings currentOpord, under Configs.", _y + 0.006, 0.08, "", PAC_UI_X, PAC_UI_W, true] call FUNC(uiText);

[[
    ["CREATE AND START WRITING", {
        private _f = [] call FUNC(uiFormRead);
        private _id = toLower (trim (_f getOrDefault ["id", ""]));
        if (_id isEqualTo "" || {(toArray _id) findIf {!(_x isEqualTo 95 || {_x >= 48 && _x <= 57} || {_x >= 97 && _x <= 122})} >= 0}) exitWith {
            ["An id is letters, digits and underscore.", true] call FUNC(uiHint)
        };
        [player, "create", _id, "header", createHashMapFromArray [["title", trim (_f getOrDefault ["title", ""])]]] remoteExec [QFUNC(adminOpord), 2];
        GVAR(uiHistory) deleteAt ((count GVAR(uiHistory)) - 1);
        ["order", createHashMapFromArray [["id", _id]]] call FUNC(uiGo);
    }]
]] call FUNC(uiButtons);
