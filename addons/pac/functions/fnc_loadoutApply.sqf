#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_loadoutApply

Description:
    The answer to FUNC(loadoutSend), on the player's machine: the kept
    loadout goes on. setUnitLoadout wants the unit local, which it is.

Parameters:
    0: The unit <OBJECT>
    1: Loadout <ARRAY>
    2: How many classes the whitelist blanked <NUMBER>

Returns:
    Whether it was applied <BOOL>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]], ["_loadout", [], [[]]], ["_dropped", 0, [0]]];

if (isNull _unit || {!local _unit} || {!alive _unit}) exitWith {false};
if (_loadout isEqualTo []) exitWith {false};

_unit setUnitLoadout _loadout;

if (_dropped > 0) then {
    ["TAC//PAC", format ["Kept loadout applied; %1 item(s) not on your role's whitelist were left out.", _dropped], [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify);
} else {
    ["TAC//PAC", "Kept loadout applied.", [0.4, 0.702, 0.4, 1]] call EFUNC(notify,notify);
};

true
