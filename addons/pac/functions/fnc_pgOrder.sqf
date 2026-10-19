#include "script_component.hpp"
/*
    File: fnc_pgOrder.sqf
    Author: YonV
    Description: One operation order - the website's ?page=opord: a tab a
        section (Header, Situation, Mission, ...), the section's fields as a
        form, SAVE writes that section only.

        WHICH SECTIONS AND FIELDS an order has is the unit's own list,
        <unit>.system.opord, when there is a database; without one it is the
        shape the mod reads (FUNC(opordDef)).

    Parameters:
        None - reads GVAR(uiArgs): id, s (the section)

    Returns:
        Nothing
*/

private _id = GVAR(uiArgs) getOrDefault ["id", ""];
private _opords = GVAR(structure) getOrDefault ["opords", createHashMap];
private _o = _opords getOrDefault [_id, createHashMap];
private _hdr = _o getOrDefault ["header", createHashMap];
private _current = GVAR(settings) getOrDefault ["currentOpord", ""];

[[_hdr getOrDefault ["title", _id], _id] select ((_hdr getOrDefault ["title", ""]) isEqualTo ""),
    format ["Operation orders  -  %1  -  Mongo doc %2.opord.%1%3", _id, GVAR(settings) getOrDefault ["unitId", ""], ["", "  -  the mission runs this one"] select (_id isEqualTo _current)]] call FUNC(uiTitle);

if !(_id in _opords) exitWith {["No such order on this server - it may still be on its way.", true] call FUNC(uiHint)};

private _def = [] call FUNC(opordDef);
private _secIds = _def apply {_x # 0};
private _sec = GVAR(uiArgs) getOrDefault ["s", _secIds param [0, "header"]];
if !(_sec in _secIds) then {_sec = _secIds param [0, "header"]};

[_def apply {[toUpper (_x # 1), _x # 0]}, _sec, {
    params ["_s"];
    ["order", createHashMapFromArray [["id", GVAR(uiArgs) get "id"], ["s", _s]]] call FUNC(uiSub);
}] call FUNC(uiSubs);

private _secDef = _def # (_secIds find _sec);
_secDef params ["", "_secTitle", "_secHint", "_fields"];
private _data = _o getOrDefault [_sec, createHashMap];
if !(_data isEqualType createHashMap) then {_data = createHashMap};

private _rows = [];
{
    _x params ["_fid", "_label", "_kind"];
    private _v = _data getOrDefault [_fid, ""];
    if (_v isEqualType []) then {_v = (_v apply {if (_x isEqualType "") then {_x} else {str _x}}) joinString (toString [10])};
    if !(_v isEqualType "") then {_v = str _v};
    _rows pushBack [_fid, _label + ([" (one per line)", ""] select (_kind isNotEqualTo "a")), ["m", "t"] select (_kind isEqualTo "t"), _v, [2, 3] select (_kind isEqualTo "x")];
} forEach _fields;
private _y = PAC_UI_TOP;
if (_secHint isNotEqualTo "") then {
    [_secHint, _y, 0.030, "", PAC_UI_X, PAC_UI_W, true] call FUNC(uiText);
    _y = _y + 0.034;
};
[_rows, _y] call FUNC(uiForm);

private _btns = [
    [format ["SAVE %1", toUpper _secTitle], {
        private _f = [] call FUNC(uiFormRead);
        private _id = GVAR(uiArgs) get "id";
        private _sec = GVAR(uiArgs) getOrDefault ["s", "header"];
        private _def = [] call FUNC(opordDef);
        private _at = (_def apply {_x # 0}) find _sec;
        if (_at < 0) exitWith {};
        private _out = createHashMap;
        {
            _x params ["_fid", "", "_kind"];
            private _v = _f getOrDefault [_fid, ""];
            if (_kind isEqualTo "a") then {
                _v = ((_v splitString (toString [10])) apply {trim _x}) select {_x isNotEqualTo ""};
            } else {
                _v = trim _v;
            };
            _out set [_fid, _v];
        } forEach ((_def # _at) # 3);
        [player, "set", _id, _sec, _out] remoteExec [QFUNC(adminOpord), 2];
        ["Saving ...", false] call FUNC(uiHint);
    }]
];
if (_id isNotEqualTo _current) then {
    _btns pushBack ["MAKE IT CURRENT", {
        [player, "currentOpord", GVAR(uiArgs) get "id"] remoteExec [QFUNC(adminSetting), 2];
        ["The mission will run this order - settings currentOpord.", false] call FUNC(uiHint);
    }];
};
_btns pushBack ["DELETE", {
    [format ["Delete the order %1? The website keeps a copy in the backup collection; the game does not.", GVAR(uiArgs) get "id"], {
        [player, "remove", GVAR(uiArgs) get "id", "", createHashMap] remoteExec [QFUNC(adminOpord), 2];
        ["orders"] call FUNC(uiGo);
    }] call FUNC(uiConfirm);
}, true];
[_btns] call FUNC(uiButtons);
