#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_toJson

Description:
    Any store value as JSON text. Strings, numbers, booleans, arrays,
    hashmaps; nil and anything else become null.

    KEYS ARE SORTED. A hashmap promises no order, and a backup that came out
    in a different order every time would defeat a diff, which is what the
    delta tool and a human comparing two exports both do with it.

    NUMBERS THAT ARE NOT NUMBERS - NaN, infinity - are written as null rather
    than as text JSON cannot read back.

Parameters:
    0: Value <ANY>
    1: Indent <STRING> (optional, "" for one line; "  " for readable)

Returns:
    JSON <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

params ["_value", ["_indent", "", [""]]];

private _fnc_string = {
    params ["_s"];
    private _out = [];
    {
        _out pushBack (switch (_x) do {
            case 34: {"\"""};                                 // backslash, quote - SQF doubles a quote to escape it
            case 92: {"\\"};                                  // backslash
            case 10: {"\n"};
            case 13: {"\r"};
            case 9:  {"\t"};
            case 8:  {"\b"};
            case 12: {"\f"};
            default {
                if (_x < 32) then {
                    // \u00XX - the two hex digits of a control code
                    private _hex = "0123456789abcdef";
                    "\u00" + (_hex select [floor (_x / 16), 1]) + (_hex select [_x mod 16, 1])
                } else {
                    toString [_x]
                }
            };
        });
    } forEach toArray _s;
    """" + (_out joinString "") + """"
};

private _fnc_value = {
    params ["_v", "_depth"];
    private _pad = "";
    private _padIn = "";
    private _nl = "";
    if (_indent isNotEqualTo "") then {
        _nl = endl;
        for "_i" from 1 to _depth do {_pad = _pad + _indent};
        _padIn = _pad + _indent;
    };

    switch (true) do {
        case (isNil "_v"): {"null"};
        case (_v isEqualType ""): {[_v] call _fnc_string};
        case (_v isEqualType true): {["false", "true"] select _v};
        case (_v isEqualType 0): {
            if (!finite _v) exitWith {"null"};
            str _v
        };
        case (_v isEqualType []): {
            if (_v isEqualTo []) exitWith {"[]"};
            private _items = _v apply {[_x, _depth + 1] call _fnc_value};
            "[" + _nl + _padIn + (_items joinString ("," + _nl + _padIn)) + _nl + _pad + "]"
        };
        case (_v isEqualType createHashMap): {
            if (count _v isEqualTo 0) exitWith {"{}"};
            // THE KEYS AS THEY ARE. `str` on a string key wraps it in quotes,
            // and a lookup by that finds nothing: every hashmap came out as
            // quoted keys with null values (found in the first in-game run,
            // 2026-09-05). A key that is not a string is written as its text.
            private _keys = +(keys _v);
            _keys sort true;
            private _items = _keys apply {
                private _k = _x;
                private _kv = _v get _k;
                private _ks = if (_k isEqualType "") then {_k} else {str _k};
                ([_ks] call _fnc_string) + ":" + (["", " "] select (_indent isNotEqualTo "")) + ([_kv, _depth + 1] call _fnc_value)
            };
            "{" + _nl + _padIn + (_items joinString ("," + _nl + _padIn)) + _nl + _pad + "}"
        };
        default {"null"};
    };
};

[_value, 0] call _fnc_value
