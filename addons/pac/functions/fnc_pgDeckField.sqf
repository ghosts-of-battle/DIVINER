#include "script_component.hpp"
/*
    File: fnc_pgDeckField.sqf
    Author: YonV
    Description: One field of a report-deck line: prefix, hint, type and
        its options (one k=v per line: min=0, max=999, choices=GREEN,AMBER,
        RED, source=mapClick, autoFill=ownCallsign, required=true).

    Parameters:
        None - reads GVAR(uiArgs): id, i, j (field index, -1 = new)

    Returns:
        Nothing
*/

private _id = GVAR(uiArgs) getOrDefault ["id", ""];
private _i = GVAR(uiArgs) getOrDefault ["i", -1];
private _j = GVAR(uiArgs) getOrDefault ["j", -1];
private _rec = (GVAR(structure) getOrDefault ["templates", createHashMap]) getOrDefault [_id, createHashMap];
private _lines = _rec getOrDefault ["lines", []];
private _line = if (_lines isEqualType [] && {_i >= 0 && _i < count _lines}) then {_lines # _i} else {["", "", []]};
private _fields = _line param [2, []];
if !(_fields isEqualType []) then {_fields = []};
private _new = _j < 0 || _j >= count _fields;
private _field = if (_new) then {["", "", "text", []]} else {_fields # _j};
if !(_field isEqualType []) then {_field = ["", "", "text", []]};

[[format ["%1.%2", _line param [0, ""], toString [65 + ((_j max 0) min 25)]], "New field"] select _new,
    format ["Templates  -  Report deck  -  %1  -  line %2 %3", _id, _i + 1, _line param [0, ""]]] call FUNC(uiTitle);

private _o = _field param [3, []];
private _oText = if (_o isEqualType []) then {
    (_o apply {if (_x isEqualType [] && {count _x >= 2}) then {format ["%1=%2", _x # 0, if ((_x # 1) isEqualType []) then {(_x # 1) joinString ","} else {_x # 1}]} else {str _x}}) joinString (toString [10])
} else {str _o};
[[
    ["prefix", "Prefix  (shown before the answer)", "t", _field param [0, ""]],
    ["hint", "Hint", "t", _field param [1, ""]],
    ["type", "Type", "c", _field param [2, "text"], [["text", "text"], ["textarea", "textarea"], ["number", "number"], ["choice", "choice"], ["bool", "bool"], ["grid", "grid"], ["callsign", "callsign"]]],
    ["opts", "Options  (k=v, one per line)", "m", _oText, 5]
], PAC_UI_TOP] call FUNC(uiForm);

private _btns = [
    ["SAVE FIELD", {
        private _f = [] call FUNC(uiFormRead);
        private _id = GVAR(uiArgs) getOrDefault ["id", ""];
        private _i = GVAR(uiArgs) getOrDefault ["i", -1];
        private _j = GVAR(uiArgs) getOrDefault ["j", -1];
        private _rec = +((GVAR(structure) getOrDefault ["templates", createHashMap]) getOrDefault [_id, createHashMap]);
        private _lines = +(_rec getOrDefault ["lines", []]);
        if !(_lines isEqualType [] && {_i >= 0 && _i < count _lines}) exitWith {["Save the line first.", true] call FUNC(uiHint)};
        private _line = +(_lines # _i);
        private _fields = _line param [2, []];
        if !(_fields isEqualType []) then {_fields = []};
        private _opts = [];
        {
            private _kv = trim _x;
            if (_kv isEqualTo "") then {continue};
            private _at = _kv find "=";
            if (_at < 0) then {_opts pushBack [_kv, "true"]} else {
                private _k = trim (_kv select [0, _at]);
                private _v = trim (_kv select [_at + 1]);
                if (_k isEqualTo "choices") then {_v = (_v splitString ",") apply {trim _x}};
                _opts pushBack [_k, _v];
            };
        } forEach ((_f getOrDefault ["opts", ""]) splitString (toString [10]));
        private _row = [trim (_f getOrDefault ["prefix", ""]), trim (_f getOrDefault ["hint", ""]), _f getOrDefault ["type", "text"], _opts];
        if (_j >= 0 && _j < count _fields) then {_fields set [_j, _row]} else {
            _fields pushBack _row;
            GVAR(uiArgs) set ["j", (count _fields) - 1];
            GVAR(uiHistory) set [(count GVAR(uiHistory)) - 1, ["deckField", GVAR(uiArgs)]];
        };
        _line set [2, _fields];
        _lines set [_i, _line];
        _rec set ["lines", _lines];
        [player, "set", _id, _rec] remoteExec [QFUNC(adminTemplate), 2];
        ["Saved.", false] call FUNC(uiHint);
    }]
];
if (!_new) then {
    _btns pushBack ["REMOVE FIELD", {
        ["Remove this field?", {
            private _id = GVAR(uiArgs) getOrDefault ["id", ""];
            private _i = GVAR(uiArgs) getOrDefault ["i", -1];
            private _j = GVAR(uiArgs) getOrDefault ["j", -1];
            private _rec = +((GVAR(structure) getOrDefault ["templates", createHashMap]) getOrDefault [_id, createHashMap]);
            private _lines = +(_rec getOrDefault ["lines", []]);
            if !(_lines isEqualType [] && {_i >= 0 && _i < count _lines}) exitWith {};
            private _line = +(_lines # _i);
            private _fields = _line param [2, []];
            if (_fields isEqualType [] && {_j >= 0 && _j < count _fields}) then {_fields deleteAt _j};
            _line set [2, _fields];
            _lines set [_i, _line];
            _rec set ["lines", _lines];
            [player, "set", _id, _rec] remoteExec [QFUNC(adminTemplate), 2];
            [] call FUNC(uiBack);
        }] call FUNC(uiConfirm);
    }, true];
};
[_btns] call FUNC(uiButtons);
