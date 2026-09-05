#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_loadoutSave

Description:
    Sends the player's current loadout to the server to be kept on their PAC
    record. Called from the gear addon's own saveLoadout, guarded on this
    addon being present - so the one "save loadout" the player already knows
    is the one that saves to PAC as well.

    Does nothing when savedLoadouts is 0; the server enforces the cap and the
    whitelist (FUNC(loadoutStore)).

Parameters:
    0: The unit <OBJECT>

Returns:
    Whether a save was sent <BOOL>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]]];

if (!hasInterface || isNull _unit || {!local _unit}) exitWith {false};
if ((GVAR(settings) getOrDefault ["savedLoadouts", 3]) isEqualTo 0) exitWith {false};

[_unit, getUnitLoadout _unit] remoteExec [QFUNC(loadoutStore), 2];
true
