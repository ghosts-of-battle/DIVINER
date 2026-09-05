#include "script_component.hpp"
/*
 * Author: SGT.Brostrom.A
 * This function strips your rank from your name if you have defined squad XML.
 *
 * Arguments:
 * 0: Unit <STRING>
 *
 * Return Value:
 *  Rank striped profileName OR profileName <STRING>
 *
 * Example:
 * [bob] call ghostD_players_fnc_unit_getName
 *
 */

params [["_unit", objNull, [objNull]]];

if (!EGVAR(init,isPlayer)) exitWith {name _unit};
if (!isMultiplayer) exitWith {profileName};

private _tag = [_unit] call FUNC(getClanTag);

// NO TAG, NO TRIM. This called ghostD_players_fnc_hasClanTag, which was never
// written, so every name lookup threw here instead of returning a name.
if (_tag isEqualTo "" || {!([_unit] call FUNC(hasClanTag))}) exitWith {profileName};

// THE TAG'S OWN LENGTH, not four characters. The old line trimmed a hard four
// off the front whatever the tag was, so a three-letter tag ate the first
// letter of the man's name and a five-letter one left a character of it behind.
private _name = profileName select [count _tag];

// And whatever separator the tag was written with - "[GoB] Yon", "GoB - Yon",
// "GoB Yon" all leave something in front of the name.
while {_name isNotEqualTo "" && {(_name select [0, 1]) in [" ", "]", ")", "-", "|", "_", "."]}} do {
    _name = _name select [1];
};

if (_name isEqualTo "") exitWith {profileName};

_name
