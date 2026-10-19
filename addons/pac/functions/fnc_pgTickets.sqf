#include "script_component.hpp"
/*
    File: fnc_pgTickets.sqf
    Author: YonV
    Description: PAC actions - the website's ?page=tickets for an admin: the
        state tabs (Open, Accepted, Declined, Closed, All) and one row a
        ticket. Members raise theirs on the tacpad's PAC tile; this is where
        an admin works them.

    Parameters:
        None - reads GVAR(uiArgs): s (the state tab)

    Returns:
        Nothing
*/

private _show = GVAR(uiArgs) getOrDefault ["s", "open"];
["PAC actions", "What members have raised - leave, a recommendation, a request, a problem"] call FUNC(uiTitle);
[[
    ["OPEN", "open"], ["ACCEPTED", "accepted"], ["DECLINED", "declined"], ["CLOSED", "closed"], ["ALL", "all"]
], _show, {
    params ["_id"];
    ["tickets", createHashMapFromArray [["s", _id]]] call FUNC(uiSub);
}] call FUNC(uiSubs);

if !(["tickets"] call FUNC(uiAsk)) exitWith {};
private _all = GVAR(uiData) getOrDefault ["tickets", []];
private _list = if (_show isEqualTo "all") then {_all} else {_all select {(_x getOrDefault ["status", "open"]) isEqualTo _show}};

private _rows = _list apply {
    private _st = _x getOrDefault ["status", "open"];
    [[
        _x getOrDefault ["id", ""],
        _x getOrDefault ["kind", ""],
        _x getOrDefault ["subject", ""],
        _x getOrDefault ["raisedByName", _x getOrDefault ["raisedBy", ""]],
        [_x getOrDefault ["about", ""]] call FUNC(uiName),
        toUpper _st,
        (_x getOrDefault ["updatedAt", ""]) select [0, 16]
    ], _x getOrDefault ["id", ""]]
};
if (_rows isEqualTo []) then {_rows = [[[format ["Nothing %1", _show], "", "", "", "", "", ""], "", [0.545, 0.592, 0.639, 1]]]};
[PAC_IDC_LIST, ["Id", "Kind", "Subject", "Raised by", "About", "State", "Updated"], [0, 0.10, 0.22, 0.54, 0.68, 0.80, 0.89], _rows, {
    params ["_id"];
    if (_id isEqualTo "") exitWith {};
    ["ticket", createHashMapFromArray [["id", _id]]] call FUNC(uiGo);
}, PAC_UI_TOP, PAC_UI_BOTTOM - PAC_UI_TOP, format ["%1 of %2", count _list, count _all]] call FUNC(uiList);

[[
    ["REFRESH", {
        GVAR(uiData) deleteAt "tickets";
        [] call FUNC(uiDraw);
    }]
]] call FUNC(uiButtons);
