#include "script_component.hpp"
/*
 * Author: Ghost
 * Checks a payload against its template. Called on the client before it sends
 * so the player is told what is missing, and again on the server before it is
 * accepted, because the client's answer is a courtesy and the server's is the
 * one that counts.
 *
 * Arguments:
 * 0: Template id <STRING>
 * 1: Payload <ARRAY> - [fieldKey, value] pairs
 *
 * Return Value:
 * 0: Accepted <BOOL>
 * 1: Why not, "" when accepted <STRING>
 *
 * Example:
 * ([_id, _payload] call ghostD_messaging_fnc_validate) params ["_ok", "_why"]
 *
 * Public: Yes
 */

params [["_templateId", "", [""]], ["_payload", [], [[]]]];

private _template = [_templateId] call FUNC(template);
if (_template isEqualTo createHashMap) exitWith {[false, format ["no such template '%1'", _templateId]]};

private _values = createHashMapFromArray _payload;
private _fields = _template get "fields";

// A field the template does not have is not an error worth refusing a report
// over - it is a template that was edited between the client composing and the
// server reading. Drop it and say so in the log, keep the rest.
{
    if !(_x in _fields) then {
        _values deleteAt _x;
        INFO_2("payload for '%1' carried unknown field '%2' - dropped",_templateId,_x);
    };
} forEach keys _values;

private _why = "";
private _seenExclusive = createHashMap;

{
    private _field = _fields get _x;
    private _value = _values getOrDefault [_x, ""];
    private _type = _field get "type";
    private _label = [_field get "prefix", _field get "lineLabel"] select (_field get "prefix" == "");

    private _empty = switch (true) do {
        case (_value isEqualType ""): {trim _value == ""};
        case (_value isEqualType false): {!_value};
        case (_value isEqualType []): {_value isEqualTo []};
        default {false};
    };

    if (_field get "required" && _empty) exitWith {
        _why = format ["%1 is required", _label];
    };

    if (_empty) then {continue};

    switch (_type) do {
        case "number": {
            // parseNumber answers 0 for "abc", so the shape is checked first -
            // otherwise every typo silently becomes zero casualties.
            if (_value isEqualType "" && {!((trim _value) regexMatch "^-?\d+(\.\d+)?$")}) exitWith {
                _why = format ["%1 must be a number", _label];
            };
            private _n = parseNumber (str _value);
            if (_n < (_field get "min") || {_n > (_field get "max")}) exitWith {
                _why = format ["%1 must be between %2 and %3", _label, _field get "min", _field get "max"];
            };
        };
        case "choice": {
            private _choices = _field get "choices";
            if (_choices isNotEqualTo [] && {!(_value in _choices)}) exitWith {
                _why = format ["%1 must be one of %2", _label, _choices joinString ", "];
            };
        };
        case "grid": {
            if !(_value isEqualType [] || _value isEqualType "") exitWith {
                _why = format ["%1 must be a position or a grid", _label];
            };
        };
        case "bool": {
            private _group = _field get "exclusive";
            if (_group != "") then {
                if (_group in _seenExclusive) exitWith {
                    _why = format ["only one of %1 may be ticked", _field get "lineLabel"];
                };
                _seenExclusive set [_group, true];
            };
        };
    };

    if (_why != "") exitWith {};
} forEach (_template get "order");

[_why == "", _why]
