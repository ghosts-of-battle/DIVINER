#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_intelId

Description:
    A marker-name stem no other product will reuse.

    Products used to stamp their name with the mission time rounded to a second.
    Two hackers cashing in the same product in the same second produced the same
    stem, and createMarkerLocal refuses a name that already exists - so the
    second player's intel silently did not draw, with nothing in the log to say
    why. A counter cannot collide.

    Server side. Every caller is already on the server, so there is one counter
    on one machine and the ids it hands out are ordered.

Parameters:
    _prefix : STRING - short tag for the product, e.g. "pic".

Returns:
    STRING - the stem.

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_prefix"];

GVAR(intelSeq) = (missionNamespace getVariable [QGVAR(intelSeq), 0]) + 1;

format [QGVAR(%1_%2), _prefix, GVAR(intelSeq)]
