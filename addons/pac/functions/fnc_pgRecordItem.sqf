#include "script_component.hpp"
/*
    File: fnc_pgRecordItem.sqf
    Author: YonV
    Description: One entry of a config - its id, name and fields as a form,
        SAVE and DELETE. The fields are FUNC(structFields)'s for the
        section, so every section the structure has is edited here without
        a screen of its own; the shapes that are not id -> record (welcome,
        logistics, pylons, settings) arrive as one through
        FUNC(structItems) and go back through FUNC(adminStructure).

    Parameters:
        None - reads GVAR(uiArgs): sec, id ("" = new), v (motorpool variant)

    Returns:
        Nothing
*/

private _sec = GVAR(uiArgs) getOrDefault ["sec", "ranks"];
private _id = GVAR(uiArgs) getOrDefault ["id", ""];
private _v = GVAR(uiArgs) getOrDefault ["v", ""];
private _new = _id isEqualTo "";
([_sec] call FUNC(uiSectionLabel)) params ["_label"];
private _unit = GVAR(settings) getOrDefault ["unitId", ""];
private _fed = [_sec] call FUNC(fileFed);

private _items = if (_v isNotEqualTo "" && _sec isEqualTo "motorpool") then {
    (GVAR(structure) getOrDefault ["motorpoolVariants", createHashMap]) getOrDefault [_v, createHashMap]
} else {
    [_sec] call FUNC(structItems)
};
private _rec = _items getOrDefault [_id, createHashMap];
if !(_rec isEqualType createHashMap) then {_rec = createHashMap};

[[_rec getOrDefault ["name", _id], "New " + toLower _label] select _new,
    format ["%1  -  %2.%3%4", _label, _unit, _sec, ["", "." + _v] select (_v isNotEqualTo "")]] call FUNC(uiTitle);

// ---- the rows -------------------------------------------------------------
private _rows = [["id", ["Id", "Steam id"] select (_sec isEqualTo "admins"), ["r", "t"] select _new, _id]];
switch (_sec) do {
    case "settings": {_rows pushBack ["name", "What it does", "r", _rec getOrDefault ["name", ""]]};
    case "promotion": {_rows pushBack ["name", "What it is", "t", _rec getOrDefault ["name", ""]]};
    case "welcome": {};
    default {_rows pushBack ["name", "Name", "t", _rec getOrDefault ["name", ""]]};
};
private _fields = ([_sec] call FUNC(structFields)) select {(_x # 2) isNotEqualTo ""};
if (_sec isEqualTo "cosmetics") then {_fields pushBack ["code", "t", "SQF", "", ""]};
{
    _x params ["_field", "_kind", "_flabel", "_hint", ["_picker", ""]];
    private _val = _rec getOrDefault [_field, ""];
    if (_sec isEqualTo "ranks" && _field isEqualTo "points") then {
        _val = ((["promotion"] call FUNC(structItems)) getOrDefault ["rank_" + _id, createHashMap]) getOrDefault ["value", 0];
    };
    private _row = switch (true) do {
        case (_picker isEqualTo "kinds"): {[_field, _flabel, "c", _val, [["bool", "yes / no"], ["number", "a number"]]]};
        case (_picker isEqualTo "ranks"): {
            private _opts = [["", "- none -"]];
            {_opts pushBack [_x, _y getOrDefault ["name", _x]]} forEach (GVAR(structure) getOrDefault ["ranks", createHashMap]);
            [_field, _flabel, "c", _val, _opts]
        };
        case (_kind isEqualTo "a"): {
            if (_val isEqualType []) then {_val = (_val apply {if (_x isEqualType "") then {_x} else {str _x}}) joinString (toString [10])};
            [_field, _flabel + " (one per line)", "m", _val, 3]
        };
        case (_kind isEqualTo "n"): {[_field, _flabel, "n", _val]};
        case (_field in ["text", "code", "description"]): {[_field, _flabel, "m", _val, [4, 8] select (_field isEqualTo "text")]};
        default {[_field, _flabel + (["", "  -  " + _hint] select (_hint isNotEqualTo ""))] + ["t", _val]};
    };
    _rows pushBack _row;
} forEach _fields;
private _y = [_rows, PAC_UI_TOP] call FUNC(uiForm);

if (_fed) exitWith {
    ["This comes from the mission's config folder and there is no database - the game cannot write a file. Change the file, or give the mission a database. Export and import are on Backup.", _y + 0.006, 0.08, "", PAC_UI_X, PAC_UI_W, true] call FUNC(uiText);
};

// ---- the actions ----------------------------------------------------------
private _btns = [
    ["SAVE", {
        private _sec = GVAR(uiArgs) getOrDefault ["sec", ""];
        private _v = GVAR(uiArgs) getOrDefault ["v", ""];
        private _f = [] call FUNC(uiFormRead);
        private _id = trim (_f getOrDefault ["id", ""]);
        if (_sec isEqualTo "welcome") then {_id = "welcome"};
        if (_id isEqualTo "") exitWith {["It needs an id.", true] call FUNC(uiHint)};
        private _rec = createHashMap;
        if ((GVAR(uiArgs) getOrDefault ["id", ""]) isNotEqualTo "" && {(GVAR(uiArgs) getOrDefault ["id", ""]) isNotEqualTo _id}) exitWith {["An id cannot be changed - make a new entry and delete this one.", true] call FUNC(uiHint)};
        {
            _x params ["_key", "_kind"];
            if (_key isEqualTo "id") then {continue};
            private _val = _f get _key;
            if (_kind isEqualTo "m" && {(_key in ["contents", "presets", "classes", "vehicles", "effects", "lines", "ids"]) || {(([_sec] call FUNC(structFields)) findIf {(_x # 0) isEqualTo _key && (_x # 1) isEqualTo "a"}) >= 0}}) then {
                _val = ((_val splitString (toString [10])) apply {trim _x}) select {_x isNotEqualTo ""};
            };
            if (_val isEqualType "") then {_val = trim _val};
            _rec set [_key, _val];
        } forEach GVAR(uiFormKeys);
        if (_v isNotEqualTo "") then {_rec set ["variant", _v]};
        [player, _sec, "set", _id, _rec] remoteExec [QFUNC(adminStructure), 2];
        [] call FUNC(uiBack);
    }]
];
if (!_new && !(_sec in ["settings", "welcome"])) then {
    _btns pushBack ["DELETE", {
        private _sec = GVAR(uiArgs) getOrDefault ["sec", ""];
        private _id = GVAR(uiArgs) getOrDefault ["id", ""];
        [format ["Delete %1 from %2?", _id, _sec], {
            private _rec = createHashMap;
            private _v = GVAR(uiArgs) getOrDefault ["v", ""];
            if (_v isNotEqualTo "") then {_rec set ["variant", _v]};
            [player, GVAR(uiArgs) getOrDefault ["sec", ""], "remove", GVAR(uiArgs) getOrDefault ["id", ""], _rec] remoteExec [QFUNC(adminStructure), 2];
            [] call FUNC(uiBack);
        }] call FUNC(uiConfirm);
    }, true];
};
[_btns] call FUNC(uiButtons);
