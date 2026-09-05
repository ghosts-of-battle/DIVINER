#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_hasPhone

Description:
    Does this enemy soldier carry a hackable cell phone? Only a percentage of
    them do (the phonePct setting) - an enemy force where every rifleman is a
    signals target is not an intel game, it is a vending machine.

    The roll is DERIVED, not rolled: hashed from the unit's netId, so every
    machine answers the same for the same man without any synchronisation, and
    the answer never changes mid-life. Cached on the unit after the first ask.

Parameters:
    _unit : OBJECT - the soldier.

Returns:
    BOOL

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_unit"];

if (isNull _unit) exitWith {false};

// The explicit override wins, both ways: a mission can strip or hand one to a
// specific man with setVariable ["ghostD_hacking_carriesPhone", true/false].
private _forced = _unit getVariable QGVAR(carriesPhone);
if (!isNil "_forced") exitWith {_forced};

private _cached = _unit getVariable QGVAR(hasPhone);
if (!isNil "_cached") exitWith {_cached};

private _pct = missionNamespace getVariable [QGVAR(phonePct), 30];

private _has = if (_pct >= 100) then {true} else {
    if (_pct <= 0) then {false} else {
        // netId is "channel:id" and identical on every machine. Two primes keep
        // consecutive ids from striping (1053, 1054, 1055 must not all agree).
        private _parts = (netId _unit) splitString ":";
        if (count _parts < 2) then {
            // no net identity (SP edge) - one machine, a plain roll is fine
            random 100 < _pct
        } else {
            private _h = (parseNumber (_parts select 0)) * 7919
                + (parseNumber (_parts select 1)) * 104729;
            (_h mod 100) < _pct
        };
    };
};

_unit setVariable [QGVAR(hasPhone), _has];
_has
