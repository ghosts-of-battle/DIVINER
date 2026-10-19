#include "script_component.hpp"
/*
    File: fnc_pgRecord.sqf
    Author: YonV
    Description: One config's list - the website's ?page=record: one row an
        entry with its id, name and first fields; a row opens the entry,
        NEW opens an empty one. Any structure section that is id -> record
        is drawn by this (FUNC(structItems) makes them all that shape).

        FED BY A FILE: when the section comes from the mission's config
        folder and there is no database, the list is shown and nothing
        else - the game cannot write a file (user, 2026-09-09).

    Parameters:
        None - reads GVAR(uiArgs): sec, v (a motorpool variant)

    Returns:
        Nothing
*/

GVAR(uiLive) = true;
private _sec = GVAR(uiArgs) getOrDefault ["sec", "ranks"];
private _v = GVAR(uiArgs) getOrDefault ["v", ""];
([_sec] call FUNC(uiSectionLabel)) params ["_label", "_blurb"];
private _unit = GVAR(settings) getOrDefault ["unitId", ""];
private _fed = [_sec] call FUNC(fileFed);

private _items = if (_v isNotEqualTo "" && _sec isEqualTo "motorpool") then {
    (GVAR(structure) getOrDefault ["motorpoolVariants", createHashMap]) getOrDefault [_v, createHashMap]
} else {
    [_sec] call FUNC(structItems)
};
[_label, format ["%1.%2%3  -  %4%5", _unit, _sec, ["", "." + _v] select (_v isNotEqualTo ""), _blurb,
    ["", "  -  FROM THE MISSION'S CONFIG FOLDER, read only in game"] select _fed]] call FUNC(uiTitle);
private _f = [] call FUNC(uiFilterShow);

private _fields = ([_sec] call FUNC(structFields)) select {(_x # 2) isNotEqualTo ""};
private _shown = _fields select [0, 3];
private _headers = ["Id", "Name"] + (_shown apply {_x # 2});
private _cols = switch (count _shown) do {
    case 0: {[0, 0.30]};
    case 1: {[0, 0.24, 0.60]};
    case 2: {[0, 0.20, 0.48, 0.74]};
    default {[0, 0.18, 0.42, 0.62, 0.82]};
};
if (_sec isEqualTo "settings") then {_headers = ["Setting", "What it does", "Value"]};
if (_sec isEqualTo "promotion") then {_headers = ["Weight", "What it is", "Value"]};

private _fnc_short = {
    private _v = _this;
    if (_v isEqualType []) then {_v = (_v apply {if (_x isEqualType "") then {_x} else {str _x}}) joinString ", "};
    if !(_v isEqualType "") then {_v = str _v};
    if (count _v > 60) then {_v = (_v select [0, 57]) + "..."};
    _v
};
private _ids = keys _items;
_ids sort true;
private _rows = [];
{
    private _rec = _items get _x;
    if !(_rec isEqualType createHashMap) then {continue};
    private _name = _rec getOrDefault ["name", ""];
    if (_f isNotEqualTo "" && {!(_f in toLower (_x + " " + _name))}) then {continue};
    private _cells = [_x, _name] + (_shown apply {(_rec getOrDefault [_x # 0, ""]) call _fnc_short});
    _rows pushBack [_cells, _x];
} forEach _ids;
if (_rows isEqualTo []) then {_rows = [[["Nothing yet"], "", [0.545, 0.592, 0.639, 1]]]};

[PAC_IDC_LIST, _headers, _cols, _rows, {
    params ["_id"];
    if (_id isEqualTo "") exitWith {};
    ["recordItem", createHashMapFromArray [["sec", GVAR(uiArgs) getOrDefault ["sec", ""]], ["id", _id], ["v", GVAR(uiArgs) getOrDefault ["v", ""]]]] call FUNC(uiGo);
}, PAC_UI_TOP, PAC_UI_BOTTOM - PAC_UI_TOP, format ["%1  %2", _label, count _items]] call FUNC(uiList);

private _btns = [];
if (!_fed && !(_sec in ["settings", "welcome"])) then {
    _btns pushBack ["NEW", {
        ["recordItem", createHashMapFromArray [["sec", GVAR(uiArgs) getOrDefault ["sec", ""]], ["id", ""], ["v", GVAR(uiArgs) getOrDefault ["v", ""]]]] call FUNC(uiGo);
    }];
};
if (_sec isEqualTo "promotion") then {
    _btns pushBack ["RANKS", {["record", createHashMapFromArray [["sec", "ranks"]]] call FUNC(uiGo)}];
};
[_btns] call FUNC(uiButtons);
