#include "script_component.hpp"
/*
 * Author: Ghost
 * Builds a thread's subject line from its root message. The subject is derived,
 * never typed: a player asked to name a report names it "asdf" once and then
 * nobody can find it again.
 *
 * A template's subject format is a string with {fieldKey} substitutions, e.g.
 * "CASEVAC · {Line1.A} · {Line2.A} pax". With no format the short title and the
 * first filled field are used, which is a poor subject but always a truthful one.
 *
 * Arguments:
 * 0: Template id <STRING>
 * 1: Payload <ARRAY> - [fieldKey, value] pairs
 *
 * Return Value:
 * Subject <STRING>
 *
 * Example:
 * private _s = ["casevac", _payload] call ghostD_messaging_fnc_subject
 *
 * Public: Yes
 */

params [["_templateId", "", [""]], ["_payload", [], [[]]]];

private _template = [_templateId] call FUNC(template);
if (_template isEqualTo createHashMap) exitWith {_templateId};

private _values = createHashMapFromArray _payload;
private _short = _template get "short";

private _fnc_text = {
    params ["_value"];
    switch (true) do {
        case (_value isEqualType ""): {trim _value};
        case (_value isEqualType 0): {str _value};
        case (_value isEqualType false): {["", "yes"] select _value};
        case (_value isEqualType []): {
            // A grid field holds a position; a subject wants the grid, not
            // three decimals of altitude.
            if (count _value >= 2 && {(_value # 0) isEqualType 0}) then {
                mapGridPosition _value
            } else {
                _value joinString " "
            };
        };
        default {""};
    };
};

private _format = _template get "subject";

if (_format == "") exitWith {
    private _first = "";
    {
        private _text = [_values getOrDefault [_x, ""]] call _fnc_text;
        if (_text != "" && _text != "yes") exitWith {_first = _text};
    } forEach (_template get "order");

    if (_first == "") then {_short} else {format ["%1 - %2", _short, _first]}
};

private _out = _format;
{
    private _token = format ["{%1}", _x];
    if (_token in _out) then {
        _out = [_out, _token, [_values getOrDefault [_x, ""]] call _fnc_text] call CBA_fnc_replace;
    };
} forEach (_template get "order");

// Anything the format asked for that the template does not have would otherwise
// sit in the subject as a literal {Line9.A}.
_out = _out regexReplace ["\{[^}]*\}", ""];

trim _out
