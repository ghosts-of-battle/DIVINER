#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_skillColor

Description:
    The colour a skill's letters are drawn in, from the structure - the
    skill's "color" field, "R,G,B" in 0-255 as the editor and the database
    hold it (user, 2026-09-05: "colour them if you can - medic, cls green,
    tl and atl yellow, pick a colour for each of the rest; needs to be a
    config doc in the storage"). Read on any machine: the structure is the
    server's copy, sent to every client.

    A skill with no colour, a colour that does not parse, or an unknown id
    gives the default back, so a panel never draws in black by accident.

Parameters:
    0: Skill id <STRING>
    1: Default <ARRAY> (optional, [r, g, b, a] 0-1; default white)

Returns:
    [r, g, b, a] in 0-1 <ARRAY>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_id", "", [""]], ["_default", [1, 1, 1, 1], [[]]]];

private _skills = (missionNamespace getVariable [QGVAR(structure), createHashMap]) getOrDefault ["skills", createHashMap];
private _rec = _skills getOrDefault [_id, createHashMap];
if !(_rec isEqualType createHashMap) exitWith {_default};

private _text = _rec getOrDefault ["color", ""];
if !(_text isEqualType "") exitWith {_default};
private _parts = (_text splitString ", ") select {_x isNotEqualTo ""};
if (count _parts < 3) exitWith {_default};

private _rgb = (_parts select [0, 3]) apply {((parseNumber _x) max 0) min 255};
[(_rgb # 0) / 255, (_rgb # 1) / 255, (_rgb # 2) / 255, _default param [3, 1]]
