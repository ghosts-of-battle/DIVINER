#include "script_component.hpp"
/*
    File: fnc_pgApplications.sqf
    Author: YonV
    Description: Applications - the website's ?page=applications: the tiles
        (waiting, in total, questions asked) and one row an applicant. The
        documents come from the database through the server
        (FUNC(adminDocs)); REFRESH asks again.

    Parameters:
        None

    Returns:
        Nothing
*/

["Applications", "Who has applied through the website, and what was answered"] call FUNC(uiTitle);
if !(["applications"] call FUNC(uiAsk)) exitWith {};
if !(["questions"] call FUNC(uiAsk)) exitWith {};

private _apps = GVAR(uiData) getOrDefault ["applications", []];
private _questions = GVAR(uiData) getOrDefault ["questions", []];
private _new = _apps select {(_x getOrDefault ["status", "new"]) isEqualTo "new"};

private _y = [[
    [count _new, "waiting"],
    [count _apps, "in total"],
    [count _questions, "questions asked"]
]] call FUNC(uiTiles);

private _rows = _apps apply {
    [[
        _x getOrDefault ["name", ""],
        _x getOrDefault ["steamId", ""],
        toUpper (_x getOrDefault ["status", "new"]),
        (_x getOrDefault ["submittedAt", ""]) select [0, 16],
        (_x getOrDefault ["decidedAt", ""]) select [0, 16]
    ], _x getOrDefault ["steamId", ""]]
};
if (_rows isEqualTo []) then {_rows = [[["Nobody has applied", "", "", "", ""], "", [0.545, 0.592, 0.639, 1]]]};
[PAC_IDC_LIST, ["Name", "Steam id", "Status", "Submitted", "Decided"], [0, 0.28, 0.50, 0.64, 0.82], _rows, {
    params ["_id"];
    if (_id isEqualTo "") exitWith {};
    ["application", createHashMapFromArray [["id", _id]]] call FUNC(uiGo);
}, _y, PAC_UI_BOTTOM - _y] call FUNC(uiList);

[[
    ["REFRESH", {
        GVAR(uiData) deleteAt "applications";
        [] call FUNC(uiDraw);
    }]
]] call FUNC(uiButtons);
