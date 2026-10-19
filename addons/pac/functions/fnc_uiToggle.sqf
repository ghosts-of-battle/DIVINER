#include "script_component.hpp"
/*
    File: fnc_uiToggle.sqf
    Author: YonV
    Description: The website's checkgrid, as a table: one row a choice with
        [ x ] or [   ] in front, a click flips it. The ticked set lives in
        GVAR(uiSel) under a name until the page saves it, and is started
        fresh whenever the page (GVAR(uiSelKey)) changes.

    Parameters:
        0: Name of the set <STRING>
        1: Choices <ARRAY> - [[id, label, extra], ...]
        2: What is ticked now <ARRAY of STRING> - used only when the set is new
        3: List idc <NUMBER>
        4: y <NUMBER>
        5: h <NUMBER>
        6: Heading <STRING>
        7: left edge <NUMBER> (optional)
        8: w <NUMBER> (optional)

    Returns:
        The ticked ids <ARRAY>
*/

params [
    ["_name", "", [""]],
    ["_choices", [], [[]]],
    ["_now", [], [[]]],
    ["_idc", PAC_IDC_LIST, [0]],
    ["_y", PAC_UI_TOP, [0]],
    ["_h", 0.3, [0]],
    ["_heading", "", [""]],
    ["_left", PAC_UI_X, [0]],
    ["_w", PAC_UI_W, [0]]
];

if (isNil QGVAR(uiSel)) then {GVAR(uiSel) = createHashMap};
private _pageKey = format ["%1/%2", GVAR(uiPage), GVAR(uiArgs) toArray false];
if ((missionNamespace getVariable [QGVAR(uiSelKey), ""]) isNotEqualTo _pageKey) then {
    GVAR(uiSel) = createHashMap;
    GVAR(uiSelKey) = _pageKey;
};
if !(_name in GVAR(uiSel)) then {GVAR(uiSel) set [_name, +_now]};
private _sel = GVAR(uiSel) get _name;

private _rows = _choices apply {
    _x params ["_id", ["_label", ""], ["_extra", ""]];
    [[["[   ]", "[ x ]"] select (_id in _sel), _label, _extra], _name + "|" + _id]
};
if (_rows isEqualTo []) then {_rows = [[["", "Nothing to choose from", ""], "", [0.545, 0.592, 0.639, 1]]]};
[_idc, ["", "", ""], [0, 0.07, 0.50], _rows, {
    params ["_data"];
    if (_data isEqualTo "") exitWith {};
    private _at = _data find "|";
    private _set = _data select [0, _at];
    private _id = _data select [_at + 1];
    private _sel = GVAR(uiSel) getOrDefault [_set, []];
    if (_id in _sel) then {_sel deleteAt (_sel find _id)} else {_sel pushBack _id};
    GVAR(uiSel) set [_set, _sel];
    [] call FUNC(uiDraw);
}, _y, _h, _heading, _left, _w] call FUNC(uiList);

_sel
