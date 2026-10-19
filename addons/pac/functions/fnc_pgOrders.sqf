#include "script_component.hpp"
/*
    File: fnc_pgOrders.sqf
    Author: YonV
    Description: Operation orders - the website's ?page=opords: one row an
        order (id, title, date, how much of it is written), the one the
        mission runs marked, and START A NEW ORDER.

    Parameters:
        None

    Returns:
        Nothing
*/

GVAR(uiLive) = true;
private _opords = GVAR(structure) getOrDefault ["opords", createHashMap];
private _current = GVAR(settings) getOrDefault ["currentOpord", ""];
["Operation orders", format ["%1 order(s)  -  the mission runs '%2' (settings currentOpord)", count _opords, [_current, "none"] select (_current isEqualTo "")]] call FUNC(uiTitle);

private _ids = keys _opords;
_ids sort true;
private _rows = _ids apply {
    private _o = _opords get _x;
    private _hdr = _o getOrDefault ["header", createHashMap];
    private _done = 0;
    private _total = 0;
    {
        if (_y isEqualType createHashMap) then {
            {
                _total = _total + 1;
                if (_y isNotEqualTo "" && _y isNotEqualTo []) then {_done = _done + 1};
            } forEach _y;
        };
    } forEach _o;
    [[
        [_x, _x + "  (current)"] select (_x isEqualTo _current),
        _hdr getOrDefault ["title", ""],
        _hdr getOrDefault ["date", ""],
        format ["%1 / %2 fields", _done, _total]
    ], _x]
};
if (_rows isEqualTo []) then {_rows = [[["No orders yet", "", "", ""], "", [0.545, 0.592, 0.639, 1]]]};
[PAC_IDC_LIST, ["Id", "Title", "Date", "Written"], [0, 0.22, 0.66, 0.82], _rows, {
    params ["_id"];
    if (_id isEqualTo "") exitWith {};
    ["order", createHashMapFromArray [["id", _id]]] call FUNC(uiGo);
}, PAC_UI_TOP, PAC_UI_BOTTOM - PAC_UI_TOP] call FUNC(uiList);

[[
    ["START A NEW ORDER", {["newOrder"] call FUNC(uiGo)}]
]] call FUNC(uiButtons);
