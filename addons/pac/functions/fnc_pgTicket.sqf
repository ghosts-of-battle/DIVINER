#include "script_component.hpp"
/*
    File: fnc_pgTicket.sqf
    Author: YonV
    Description: One PAC action - the website's ?page=ticket: what it is,
        the thread, and ADD TO IT with a reply, a private flag and a state
        change. The reply goes through the server (FUNC(adminTicket)), which
        sends the tickets back.

    Parameters:
        None - reads GVAR(uiArgs): id

    Returns:
        Nothing
*/

private _id = GVAR(uiArgs) getOrDefault ["id", ""];
if !(["tickets"] call FUNC(uiAsk)) exitWith {};
private _all = GVAR(uiData) getOrDefault ["tickets", []];
private _at = _all findIf {(_x getOrDefault ["id", ""]) isEqualTo _id};
if (_at < 0) exitWith {["PAC action", "PAC actions"] call FUNC(uiTitle); ["No such PAC action.", true] call FUNC(uiHint)};
private _t = _all # _at;
private _status = _t getOrDefault ["status", "open"];

[_t getOrDefault ["subject", _id], format ["PAC actions  -  %1  -  %2  -  %3  -  raised by %4 %5  -  about %6",
    _id, _t getOrDefault ["kind", ""], toUpper _status,
    _t getOrDefault ["raisedByName", ""], _t getOrDefault ["raisedBy", ""],
    [_t getOrDefault ["about", ""]] call FUNC(uiName)]] call FUNC(uiTitle);

// The thread: one row a reply, the text wrapped by hand into rows of its
// own under it, because a table row is one line.
private _rows = [];
{
    private _r = _x;
    private _head = format ["%1  %2", (_r getOrDefault ["at", ""]) select [0, 16], _r getOrDefault ["byName", ""]];
    private _marks = [];
    private _st = _r getOrDefault ["status", ""];
    if (_st isEqualType "" && _st isNotEqualTo "") then {_marks pushBack ("marked " + toUpper _st)};
    if (_r getOrDefault ["private", false]) then {_marks pushBack "PRIVATE"};
    _rows pushBack [[_head, _marks joinString "  "], "", [0.545, 0.592, 0.639, 1]];
    private _text = _r getOrDefault ["text", ""];
    if !(_text isEqualType "") then {_text = str _text};
    {
        private _line = _x;
        while {count _line > 110} do {
            // break at the last space before the edge, or at the edge
            private _last = 110;
            for "_i" from 109 to 60 step -1 do {if ((_line select [_i, 1]) isEqualTo " ") exitWith {_last = _i}};
            _rows pushBack [["    " + (_line select [0, _last]), ""], ""];
            _line = _line select [_last + 1];
        };
        _rows pushBack [["    " + _line, ""], ""];
    } forEach (_text splitString (toString [10]));
} forEach (_t getOrDefault ["replies", []]);

private _listH = PAC_UI_BOTTOM - PAC_UI_TOP - 0.150;
[PAC_IDC_LIST, [], [0, 0.70], _rows, {}, PAC_UI_TOP, _listH, format ["Thread  %1", count (_t getOrDefault ["replies", []])]] call FUNC(uiList);

private _states = [["", "leave as " + _status]];
{if (_x isNotEqualTo _status) then {_states pushBack [_x, toUpper _x]}} forEach ["open", "accepted", "declined", "closed"];
[[
    ["text", "Reply", "m", "", 2],
    ["private", "Private note - only admins see it", "b", false],
    ["status", "Change the state", "c", "", _states]
], PAC_UI_TOP + _listH + 0.008] call FUNC(uiForm);

[[
    ["SEND", {
        private _f = [] call FUNC(uiFormRead);
        private _text = trim (_f getOrDefault ["text", ""]);
        private _st = _f getOrDefault ["status", ""];
        if (_text isEqualTo "" && _st isEqualTo "") exitWith {["Nothing to add.", true] call FUNC(uiHint)};
        [player, GVAR(uiArgs) get "id", _text, _st, _f getOrDefault ["private", false]] remoteExec [QFUNC(adminTicket), 2];
        GVAR(uiWaiting) pushBackUnique "tickets";
        ["Sending ...", false] call FUNC(uiHint);
    }]
]] call FUNC(uiButtons);
