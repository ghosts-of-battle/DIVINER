#include "script_component.hpp"
/*
    File: fnc_pgDocs.sqf
    Author: YonV
    Description: Mongo docs - the website's ?page=documents: every document
        under the unit's prefix, filterable by key; a row opens it.

    Parameters:
        None

    Returns:
        Nothing
*/

private _unit = GVAR(settings) getOrDefault ["unitId", ""];
["Mongo docs", format ["Every document whose key starts with %1", _unit]] call FUNC(uiTitle);
private _f = [] call FUNC(uiFilterShow);
if !(["docs"] call FUNC(uiAsk)) exitWith {};

private _keys = GVAR(uiData) getOrDefault ["docs", []];
if !(_keys isEqualType []) then {_keys = []};
_keys = +_keys;
_keys sort true;
private _rows = [];
{
    if (_f isNotEqualTo "" && {!(_f in toLower _x)}) then {continue};
    private _rest = _x select [count _unit + 1];
    private _section = (_rest splitString ".") param [0, ""];
    if (_x isEqualTo _unit) then {_section = "the store"};
    _rows pushBack [[_x, _section], _x];
} forEach _keys;
if (_rows isEqualTo []) then {_rows = [[["Nothing", ""], "", [0.545, 0.592, 0.639, 1]]]};
[PAC_IDC_LIST, ["Key", "Section"], [0, 0.60], _rows, {
    params ["_key"];
    if (_key isEqualTo "") exitWith {};
    ["doc", createHashMapFromArray [["key", _key]]] call FUNC(uiGo);
}, PAC_UI_TOP, PAC_UI_BOTTOM - PAC_UI_TOP, format ["%1 of %2", count _rows, count _keys]] call FUNC(uiList);

[[
    ["REFRESH", {GVAR(uiData) deleteAt "docs"; [] call FUNC(uiDraw)}]
]] call FUNC(uiButtons);
