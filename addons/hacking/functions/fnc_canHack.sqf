#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_canHack

Description:
    Full gate for hacking. Two things, in cheapest-first order:

      1. the feature is enabled;
      2. the unit IS flagged ISR - the same flag Intel Hunt processing uses, so
         a mission marks its operators once.

    THERE IS NO LONGER A CARRIED-KIT CHECK. Hacking used to also demand the
    Intrusion Tablet in your pockets, which made it two gates saying nearly the
    same thing: a mission that marks a man as its ISR operator has already
    decided he is equipped for it, and the second check only ever caught the
    case where somebody forgot to pack an item the loadout should have given
    them. Training is the gate; the tablet is kit.

    FUNC(tabletOpen) calls this to produce its refusal message, so there is one
    answer to "can this man hack" rather than one per caller.

    Pure variable checks plus the mission condition, so nothing here depends on
    an items mod being loaded.

Parameters:
    _unit : OBJECT - the player.

Returns:
    BOOL

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_unit"];

if !(GVAR(enabled)) exitWith { false };

if (GVAR(requireISR) && {!([_unit] call EFUNC(common,isISR))}) exitWith { false };

private _src = GVAR(condition);
if (_src isEqualTo "" || _src isEqualTo "true") exitWith { true };

if (_src isNotEqualTo (missionNamespace getVariable [QGVAR(conditionSource), ""])) then {
    GVAR(conditionSource) = _src;
    GVAR(conditionCode) = compile _src;
};

(_unit call GVAR(conditionCode)) isEqualTo true
