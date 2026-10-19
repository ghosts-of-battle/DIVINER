#include "script_component.hpp"
/*
    File: fnc_pgTicketKind.sqf
    Author: YonV
    Description: One PAC request kind - id, what it is shown as, what to
        put in it. SAVE and DELETE (tickets already raised keep the kind).

    Parameters:
        None - reads GVAR(uiArgs): id ("" = new)

    Returns:
        Nothing
*/

private _id = GVAR(uiArgs) getOrDefault ["id", ""];
private _new = _id isEqualTo "";
if !(["ticketKinds"] call FUNC(uiAsk)) exitWith {};
private _kinds = GVAR(uiData) getOrDefault ["ticketKinds", createHashMap];
private _k = _kinds getOrDefault [_id, createHashMap];
if !(_k isEqualType createHashMap) then {_k = createHashMap};

[[_k getOrDefault ["label", _id], "New request kind"] select _new, "Templates  -  System  -  PAC request kinds"] call FUNC(uiTitle);
[[
    ["id", "Id  (a-z, digits, underscore)", ["r", "t"] select _new, _id],
    ["label", "Shown as", "t", _k getOrDefault ["label", ""]],
    ["hint", "What to put in it", "t", _k getOrDefault ["hint", ""]]
], PAC_UI_TOP] call FUNC(uiForm);

private _btns = [
    ["SAVE", {
        private _f = [] call FUNC(uiFormRead);
        private _id = toLower (trim (_f getOrDefault ["id", ""]));
        if (_id isEqualTo "" || {(toArray _id) findIf {!(_x isEqualTo 95 || {_x >= 48 && _x <= 57} || {_x >= 97 && _x <= 122})} >= 0}) exitWith {["An id is lower case letters, digits and underscore.", true] call FUNC(uiHint)};
        [player, "set", _id, trim (_f getOrDefault ["label", ""]), trim (_f getOrDefault ["hint", ""])] remoteExec [QFUNC(adminTicketKind), 2];
        GVAR(uiData) deleteAt "ticketKinds";
        ["ticketKinds"] call FUNC(uiGo);
    }]
];
if (!_new) then {
    _btns pushBack ["DELETE", {
        ["Delete this kind? Tickets already raised keep it.", {
            [player, "remove", GVAR(uiArgs) getOrDefault ["id", ""], "", ""] remoteExec [QFUNC(adminTicketKind), 2];
            GVAR(uiData) deleteAt "ticketKinds";
            ["ticketKinds"] call FUNC(uiGo);
        }] call FUNC(uiConfirm);
    }, true];
};
[_btns] call FUNC(uiButtons);
