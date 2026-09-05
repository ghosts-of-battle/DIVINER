#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_lookup

Description:
    A display field off a structure id, or a marker that the id is dead.

    THE ONE PLACE AN ID BECOMES A NAME. Every roster row, record page and OPORD
    line turns a rankId into an abbreviation or a roleId into a title, and every
    one of them has to answer the same question when the id is not in the
    structure any more: it says so, in a way that reads as a fault rather than as
    a blank, because a blank is what a player with no rank looks like and those
    are different facts.

    Empty in, empty out. An unassigned field is not an orphan.

Parameters:
    0: Section - "ranks", "skills", "awards", "statuses", "roles", "opords" <STRING>
    1: The id <STRING>
    2: The field wanted <STRING> (optional, default "name")

Returns:
    The field, "" for no id, or "(<id>?)" for an id the structure has lost <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_section", "", [""]], ["_id", "", [""]], ["_field", "name", [""]]];

if (_id isEqualTo "") exitWith {""};

private _rec = (GVAR(structure) getOrDefault [_section, createHashMap]) getOrDefault [_id, createHashMap];

if (count _rec isEqualTo 0) exitWith { format ["(%1?)", _id] };

private _v = _rec getOrDefault [_field, ""];
if (_v isEqualType "") then {_v} else {str _v}
