#include "script_component.hpp"
/*
    File: fnc_pgAddOperator.sqf
    Author: YonV
    Description: Add an operator - the website's "Add an operator" card on
        the roster: someone who has not played yet, put on the roster before
        they do. Steam id and name; the rest goes on their page.

    Parameters:
        None

    Returns:
        Nothing
*/

["Add an operator", "Roster"] call FUNC(uiTitle);

private _y = [[
    ["uid", "Steam id", "t", ""],
    ["name", "Name", "t", ""]
], PAC_UI_TOP] call FUNC(uiForm);
["A 17-digit Steam id. The record is seeded like a first connect; rank, role and the rest are set on their page.", _y + 0.006, 0.08, "", PAC_UI_X, PAC_UI_W, true] call FUNC(uiText);

[[
    ["ADD TO ROSTER", {
        private _f = [] call FUNC(uiFormRead);
        private _uid = trim (_f getOrDefault ["uid", ""]);
        private _name = trim (_f getOrDefault ["name", ""]);
        if (_uid isEqualTo "" || {(toArray _uid) findIf {!(_x >= 48 && _x <= 57)} >= 0}) exitWith {["A Steam id is digits only.", true] call FUNC(uiHint)};
        [player, _uid, _name] remoteExec [QFUNC(adminAddOperator), 2];
        ["roster"] call FUNC(uiGo);
    }]
]] call FUNC(uiButtons);
