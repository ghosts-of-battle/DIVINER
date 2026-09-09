#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_roleFieldText

Description:
    One field of a role, written for an edit box.

    NOT EVERY ROLE FIELD IS A LIST OF WORDS. The editor's generic path joins an
    array with ", " and splits it back on commas, which is right for
    requiredSkills and wrong for four of them:

        nets, tiles          [[name, "true"], ...]     - pairs
        traits               [[name, value, custom], ...]
        customVariables      [[name, value, global], ...]
        defaultLoadout       a nested array, ten slots deep in places

    Joining those with ", " gives "[C2,true], [FIRES,true]" or worse, and
    splitting that back on commas gives a role with a net called "[C2" - which
    is a net nobody is on, with nothing to say so. So each shape gets written
    the way a person would write it, and FUNC(roleFieldParse) reads exactly
    that back.

        nets, tiles          C2, C2.reports, FIRES.cas
        traits               UAVHacker=true, audibleCoef=0.9
        customVariables      isLeader=true, ace_medical_medicClass=1
        defaultLoadout       {"arifle_MX_F",...}   - the config's own spelling

    A pair whose flag is false is written name=false, so turning one off is
    possible without deleting the row.

Parameters:
    0: Field name <STRING>
    1: The stored value <ANY>

Returns:
    The text for the edit box <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_field", "", [""]], ["_v", ""]];

// The one field that is genuinely nested; it gets the config spelling.
if (_field isEqualTo "defaultLoadout") exitWith {
    if !(_v isEqualType []) exitWith {""};
    if (_v isEqualTo []) exitWith {""};
    [_v] call FUNC(sqfText)
};

private _isFlag = _field in ["nets", "tiles"];
private _isPair = _field in ["traits", "customVariables"];

if (_isFlag || _isPair) exitWith {
    if !(_v isEqualType []) exitWith {""};
    private _out = [];
    {
        if !(_x isEqualType []) then {continue};
        private _name = _x param [0, ""];
        if (!(_name isEqualType "") || _name isEqualTo "") then {continue};
        private _val = _x param [1, "true"];
        if !(_val isEqualType "") then {_val = str _val};
        // A net or tile that is ON is just its name - which is every one of
        // them in practice, and the reason this reads as a list at all.
        if (_isFlag && {(toLower trim _val) in ["true", "1", "yes"]}) then {
            _out pushBack _name;
        } else {
            _out pushBack (_name + "=" + _val);
        };
    } forEach _v;
    _out joinString ", "
};

// Everything else is a flat list or a plain value.
if (_v isEqualType []) exitWith {(_v apply {if (_x isEqualType "") then {_x} else {str _x}}) joinString ", "};
if (_v isEqualType "") exitWith {_v};
str _v
