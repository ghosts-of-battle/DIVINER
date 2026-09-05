#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_hudSetPos

Description:
    Stores a HUD position for this player. Fractions of the safe zone, not screen
    pixels, so it stays sane across resolutions.

Parameters:
    _id : STRING - HUD identifier.
    _fr : ARRAY  - [x, y] in safezone fractions, or [] to clear back to default.

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_id", "", [""]], ["_fr", [], [[]]]];

if (_id isEqualTo "") exitWith {};

private _key = format [QGVAR(hud_%1), _id];
if (_fr isEqualTo []) then {
    profileNamespace setVariable [_key, nil];
} else {
    profileNamespace setVariable [_key, _fr];
};
saveProfileNamespace;
