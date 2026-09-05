#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_opordField

Description:
    One field of the current OPORD, by "section.field" - what the METT-TC
    template's autoFill = "pac:situation.enemy" asks the compose card for.
    Any machine; the structure is everywhere.

Parameters:
    0: Path <STRING> - "section.field", e.g. "mission.mission"

Returns:
    The text, "" if there is no current OPORD or no such field <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_path", "", [""]]];

private _id = GVAR(settings) getOrDefault ["currentOpord", ""];
if (_id isEqualTo "") exitWith {""};

private _parts = _path splitString ".";
if (count _parts < 2) exitWith {""};

private _opord = (GVAR(structure) getOrDefault ["opords", createHashMap]) getOrDefault [_id, createHashMap];
private _v = (_opord getOrDefault [_parts # 0, createHashMap]) getOrDefault [_parts # 1, ""];
if (_v isEqualType []) then {_v = _v joinString ", "};
if !(_v isEqualType "") then {_v = str _v};

_v
