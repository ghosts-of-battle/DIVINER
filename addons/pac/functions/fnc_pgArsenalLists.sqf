#include "script_component.hpp"
/*
    File: fnc_pgArsenalLists.sqf
    Author: YonV
    Description: One arsenal version's lists - weapons, magazines,
        backpacks, the items* lists - one row each with its count. A row
        opens the list; NEW LIST adds one. "?" as the version asks for a
        name first.

    Parameters:
        None - reads GVAR(uiArgs): v ("" = Default)

    Returns:
        Nothing
*/

GVAR(uiLive) = true;
private _v = GVAR(uiArgs) getOrDefault ["v", ""];
private _unit = GVAR(settings) getOrDefault ["unitId", ""];
private _ars = GVAR(structure) getOrDefault ["arsenal", createHashMap];
private _fed = ["arsenal"] call FUNC(fileFed);

if (_v isEqualTo "?") exitWith {
    GVAR(uiLive) = false;
    ["New arsenal version", "Templates  -  Common arsenal"] call FUNC(uiTitle);
    private _y = [[["v", "Version name  (letters, digits, underscore)", "t", ""]], PAC_UI_TOP] call FUNC(uiForm);
    ["Opens empty; saving a list in it creates the document " + _unit + ".arsenal.<name>. A mission runs it with settings currentArsenal, or an order of battle names it.", _y + 0.006, 0.08, "", PAC_UI_X, PAC_UI_W, true] call FUNC(uiText);
    [[["OPEN IT", {
        private _f = [] call FUNC(uiFormRead);
        private _name = trim (_f getOrDefault ["v", ""]);
        if (_name isEqualTo "" || {(toArray _name) findIf {!(_x isEqualTo 95 || {_x >= 48 && _x <= 57} || {_x >= 65 && _x <= 90} || {_x >= 97 && _x <= 122})} >= 0}) exitWith {["Letters, digits and underscore.", true] call FUNC(uiHint)};
        GVAR(uiHistory) deleteAt ((count GVAR(uiHistory)) - 1);
        ["arsenalLists", createHashMapFromArray [["v", _name]]] call FUNC(uiGo);
    }]]] call FUNC(uiButtons);
};

private _lists = if (_v isEqualTo "") then {_ars getOrDefault ["lists", createHashMap]} else {
    (_ars getOrDefault ["variants", createHashMap]) getOrDefault [_v, createHashMap]
};
if !(_lists isEqualType createHashMap) then {_lists = createHashMap};

[[_v, "Common arsenal"] select (_v isEqualTo ""), format ["Templates  -  %1.arsenal%2  -  %3 list(s)%4", _unit, ["", "." + _v] select (_v isNotEqualTo ""), count _lists,
    ["", "  -  from the config folder, read only in game"] select _fed]] call FUNC(uiTitle);

private _order = ["weapons", "magazines", "backpacks", "itemsUniforms", "itemsHeadgear", "itemsVests", "itemsFacewear", "itemsNvgs", "itemsOptics", "itemsMuzzles", "itemsPointersLights", "itemsBipods", "itemsBinoculars", "itemsMedical", "itemsTools"];
private _ids = keys _lists;
_ids sort true;
_ids = (_order select {_x in _ids}) + (_ids select {!(_x in _order)});
private _rows = _ids apply {
    private _l = _lists get _x;
    if !(_l isEqualType []) then {_l = []};
    [[_x, str (count _l), ["", "merged into items"] select ((_x select [0, 5]) isEqualTo "items")], _x]
};
if (_rows isEqualTo []) then {_rows = [[["No lists yet", "", ""], "", [0.545, 0.592, 0.639, 1]]]};
[PAC_IDC_LIST, ["List", "Classnames", ""], [0, 0.30, 0.44], _rows, {
    params ["_name"];
    if (_name isEqualTo "") exitWith {};
    ["arsenalList", createHashMapFromArray [["v", GVAR(uiArgs) getOrDefault ["v", ""]], ["name", _name]]] call FUNC(uiGo);
}, PAC_UI_TOP, PAC_UI_BOTTOM - PAC_UI_TOP] call FUNC(uiList);

private _btns = [];
if (!_fed) then {
    _btns pushBack ["NEW LIST", {["arsenalList", createHashMapFromArray [["v", GVAR(uiArgs) getOrDefault ["v", ""]], ["name", ""]]] call FUNC(uiGo)}];
};
[_btns] call FUNC(uiButtons);
