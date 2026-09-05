#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_ensureSafeLanding

Description:
    Watches a parachuted object down. Damage is disabled for the descent; below
    0.6 m ATL the object is detached, any nearby drop chutes are cut loose and
    deleted 30 s later, and damage is restored once it is on the ground.

Parameters:
    _toDrop : OBJECT - the parachuted object.

Returns:
    Nothing.

Author:
    Mr H. (original, MRHMilsimTools, ADPL-SA), ported by Ghost
---------------------------------------------------------------------------- */
params ["_toDrop"];

_toDrop allowDamage false;

// cut the chutes just above the deck so the object does not land attached
[
    { ((getPosATL (_this select 0)) select 2) < 0.6 },
    {
        params ["_toDrop"];
        detach _toDrop;
        {
            detach _x;
            _x setVelocity [5, 0, 0];
            [{ if (!isNull _this) then { deleteVehicle _this } }, _x, 30] call CBA_fnc_waitAndExecute;
        } forEach (nearestObjects [_toDrop, ["O_Parachute_02_F"], 10]);
        _toDrop setVelocity [0, 0, -5];
    },
    [_toDrop]
] call CBA_fnc_waitUntilAndExecute;

[
    { isTouchingGround (_this select 0) },
    {
        params ["_toDrop"];
        _toDrop setVelocity [0, 0, 0];
        _toDrop allowDamage true;
    },
    [_toDrop]
] call CBA_fnc_waitUntilAndExecute;
