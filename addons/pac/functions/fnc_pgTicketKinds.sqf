#include "script_component.hpp"
/*
    File: fnc_pgTicketKinds.sqf
    Author: YonV
    Description: PAC request kinds - what a member can raise - the
        website's Templates > System block. One row a kind; NEW KIND.

    Parameters:
        None

    Returns:
        Nothing
*/

["PAC request kinds", format ["Templates  -  System  -  %1.system.ticketKinds", GVAR(settings) getOrDefault ["unitId", ""]]] call FUNC(uiTitle);
if !(["ticketKinds"] call FUNC(uiAsk)) exitWith {};
private _kinds = GVAR(uiData) getOrDefault ["ticketKinds", createHashMap];
if !(_kinds isEqualType createHashMap) then {_kinds = createHashMap};

private _ids = keys _kinds;
_ids sort true;
private _rows = _ids apply {
    private _k = _kinds get _x;
    if !(_k isEqualType createHashMap) then {_k = createHashMap};
    [[_x, _k getOrDefault ["label", _x], _k getOrDefault ["hint", ""]], _x]
};
if (_rows isEqualTo []) then {_rows = [[["No kinds - nobody can raise a request until there is one", "", ""], "", [0.894, 0.341, 0.290, 1]]]};
[PAC_IDC_LIST, ["Id", "Shown as", "What to put in it"], [0, 0.20, 0.46], _rows, {
    params ["_id"];
    if (_id isEqualTo "") exitWith {};
    ["ticketKind", createHashMapFromArray [["id", _id]]] call FUNC(uiGo);
}, PAC_UI_TOP, PAC_UI_BOTTOM - PAC_UI_TOP, format ["Kinds  %1", count _kinds]] call FUNC(uiList);

[[
    ["NEW KIND", {["ticketKind", createHashMapFromArray [["id", ""]]] call FUNC(uiGo)}],
    ["REFRESH", {GVAR(uiData) deleteAt "ticketKinds"; [] call FUNC(uiDraw)}]
]] call FUNC(uiButtons);
