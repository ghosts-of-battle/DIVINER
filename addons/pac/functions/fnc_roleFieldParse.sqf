#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_roleFieldParse

Description:
    The other half of FUNC(roleFieldText): an edit box back into the shape the
    role is stored in. Whatever that one writes, this reads.

        nets, tiles          C2, FIRES.cas=false   -> [["C2","true"],["FIRES.cas","false"]]
        traits               UAVHacker=true        -> [["UAVHacker","true","false"]]
        customVariables      isLeader=true         -> [["isLeader","true","true"]]
        defaultLoadout       {"arifle_MX_F",...}   -> the array

    THE THIRD VALUE IS NOT GUESSED WHERE IT MATTERS. A trait's third element is
    setUnitTrait's custom flag, and a name the engine does not have needs it
    true or the trait is thrown away without a word - so it is decided by
    whether the name is one of the engine's seven, not by whoever typed it. A
    custom variable's third element is the global flag and defaults true, which
    is what every role in the framework uses.

    AN EXISTING ROW KEEPS ITS THIRD VALUE. A role that deliberately set a
    variable local, or a trait custom against the rule, is not corrected by
    somebody editing the list - the old rows are passed in and matched by name.

Parameters:
    0: Field name <STRING>
    1: The text <STRING>
    2: The rows as they are now <ARRAY> (optional) - to keep third values

Returns:
    The value to store <ANY>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_field", "", [""]], ["_text", "", [""]], ["_was", [], [[]]]];

// getAllUnitTraits' names - the only ones setUnitTrait takes with custom false.
#define ENGINE_TRAITS ["audiblecoef", "camouflagecoef", "loadcoef", "medic", "engineer", "explosivespecialist", "uavhacker"]

if (_field isEqualTo "defaultLoadout") exitWith {
    private _t = trim _text;
    if (_t isEqualTo "") exitWith {[]};
    // Braces are how a config writes an array and how CAPTURE wrote this one;
    // brackets are how SQF writes it, and somebody will paste one of those.
    // Compiled inside try/catch: this is a text box, and a bad paste must not
    // stop a mission or take the rest of the role with it.
    private _sqf = [_t, "{", "["] call CBA_fnc_replace;
    _sqf = [_sqf, "}", "]"] call CBA_fnc_replace;
    private _out = [];
    private _code = {};
    try {
        _code = compile ("[] + (" + _sqf + ")");
    } catch {
        _code = {};
    };
    if (_code isNotEqualTo {}) then {
        private _r = call _code;
        if (_r isEqualType []) then {_out = _r};
    };
    _out
};

private _isFlag = _field in ["nets", "tiles"];
private _isPair = _field in ["traits", "customVariables"];

if (_isFlag || _isPair) exitWith {
    private _out = [];
    {
        private _row = trim _x;
        if (_row isEqualTo "") then {continue};
        private _name = _row;
        private _val = "true";
        private _at = _row find "=";
        if (_at > -1) then {
            _name = trim (_row select [0, _at]);
            _val = trim (_row select [_at + 1]);
        };
        if (_name isEqualTo "") then {continue};

        // NOT exitWith. Inside forEach it ends the LOOP, not the iteration, so
        // a role would keep its first net and lose every one after it.
        if (_isFlag) then {
            _out pushBack [_name, _val];
            continue;
        };

        // A row that was there keeps whatever third value it had.
        private _third = "";
        {
            if (_x isEqualType [] && {(_x param [0, ""]) isEqualTo _name}) exitWith {
                _third = _x param [2, ""];
                if !(_third isEqualType "") then {_third = str _third};
            };
        } forEach _was;

        if (_third isEqualTo "") then {
            _third = if (_field isEqualTo "traits") then {
                // custom: true unless the engine already has the name
                ["true", "false"] select ((toLower _name) in ENGINE_TRAITS)
            } else {
                "true"                       // customVariables: global
            };
        };
        _out pushBack [_name, _val, _third];
    } forEach (_text splitString ",");
    _out
};

// Everything else is the flat list the generic path already handled.
((_text splitString ",") apply {trim _x}) select {_x isNotEqualTo ""}
