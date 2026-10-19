#include "script_component.hpp"
/*
    File: fnc_pgDeckLine.sqf
    Author: YonV
    Description: One line of a report-deck template: its key and label,
        and its fields as a table. A field opens on its own page.

    Parameters:
        None - reads GVAR(uiArgs): id, i (line index, -1 = new)

    Returns:
        Nothing
*/

private _id = GVAR(uiArgs) getOrDefault ["id", ""];
private _i = GVAR(uiArgs) getOrDefault ["i", -1];
private _rec = (GVAR(structure) getOrDefault ["templates", createHashMap]) getOrDefault [_id, createHashMap];
private _lines = +(_rec getOrDefault ["lines", []]);
if !(_lines isEqualType []) then {_lines = []};
private _new = _i < 0 || _i >= count _lines;
private _line = if (_new) then {["", "", []]} else {_lines # _i};
if !(_line isEqualType []) then {_line = ["", "", []]};

[[format ["Line %1", _i + 1], "New line"] select _new, format ["Templates  -  Report deck  -  %1  -  %2", _id, _rec getOrDefault ["title", ""]]] call FUNC(uiTitle);

private _y = [[
    ["key", "Key  (the line's title; fields are KEY.A, KEY.B ...)", "t", _line param [0, ""]],
    ["label", "Label", "t", _line param [1, ""]]
], PAC_UI_TOP] call FUNC(uiForm);

private _fields = _line param [2, []];
if !(_fields isEqualType []) then {_fields = []};
private _rows = [];
{
    if (_x isEqualType []) then {
        private _o = _x param [3, []];
        if (_o isEqualType []) then {_o = (_o apply {if (_x isEqualType [] && {count _x >= 2}) then {format ["%1=%2", _x # 0, _x # 1]} else {str _x}}) joinString "  "};
        if !(_o isEqualType "") then {_o = str _o};
        _rows pushBack [[format ["%1.%2", _line param [0, ""], toString [65 + (_forEachIndex min 25)]], _x param [0, ""], _x param [1, ""], _x param [2, "text"], _o], str _forEachIndex];
    };
} forEach _fields;
if (_rows isEqualTo []) then {_rows = [[["No fields yet", "", "", "", ""], "", [0.545, 0.592, 0.639, 1]]]};
[PAC_IDC_LIST, ["Key", "Prefix", "Hint", "Type", "Options"], [0, 0.12, 0.34, 0.60, 0.72], _rows, {
    params ["_j"];
    if (_j isEqualTo "") exitWith {};
    ["deckField", createHashMapFromArray [["id", GVAR(uiArgs) getOrDefault ["id", ""]], ["i", GVAR(uiArgs) getOrDefault ["i", -1]], ["j", parseNumber _j]]] call FUNC(uiGo);
}, _y + 0.006, PAC_UI_BOTTOM - _y - 0.006, format ["Fields  %1", count _fields]] call FUNC(uiList);

private _btns = [
    ["SAVE LINE", {
        private _f = [] call FUNC(uiFormRead);
        private _id = GVAR(uiArgs) getOrDefault ["id", ""];
        private _i = GVAR(uiArgs) getOrDefault ["i", -1];
        private _rec = +((GVAR(structure) getOrDefault ["templates", createHashMap]) getOrDefault [_id, createHashMap]);
        private _lines = +(_rec getOrDefault ["lines", []]);
        if !(_lines isEqualType []) then {_lines = []};
        private _key = trim (_f getOrDefault ["key", ""]);
        if (_key isEqualTo "") exitWith {["The line needs a key.", true] call FUNC(uiHint)};
        _key = [_key, " ", ""] call CBA_fnc_replace;
        private _fields = if (_i >= 0 && _i < count _lines) then {(_lines # _i) param [2, []]} else {[]};
        private _row = [_key, trim (_f getOrDefault ["label", ""]), _fields];
        if (_i >= 0 && _i < count _lines) then {_lines set [_i, _row]} else {
            _lines pushBack _row;
            GVAR(uiArgs) set ["i", (count _lines) - 1];
            GVAR(uiHistory) set [(count GVAR(uiHistory)) - 1, ["deckLine", GVAR(uiArgs)]];
        };
        _rec set ["lines", _lines];
        [player, "set", _id, _rec] remoteExec [QFUNC(adminTemplate), 2];
        ["Saved.", false] call FUNC(uiHint);
    }]
];
if (!_new) then {
    _btns pushBack ["ADD FIELD", {["deckField", createHashMapFromArray [["id", GVAR(uiArgs) getOrDefault ["id", ""]], ["i", GVAR(uiArgs) getOrDefault ["i", -1]], ["j", -1]]] call FUNC(uiGo)}];
    _btns pushBack ["REMOVE LINE", {
        ["Remove this line and its fields?", {
            private _id = GVAR(uiArgs) getOrDefault ["id", ""];
            private _i = GVAR(uiArgs) getOrDefault ["i", -1];
            private _rec = +((GVAR(structure) getOrDefault ["templates", createHashMap]) getOrDefault [_id, createHashMap]);
            private _lines = +(_rec getOrDefault ["lines", []]);
            if (_i >= 0 && _i < count _lines) then {_lines deleteAt _i};
            _rec set ["lines", _lines];
            [player, "set", _id, _rec] remoteExec [QFUNC(adminTemplate), 2];
            [] call FUNC(uiBack);
        }] call FUNC(uiConfirm);
    }, true];
};
[_btns] call FUNC(uiButtons);
