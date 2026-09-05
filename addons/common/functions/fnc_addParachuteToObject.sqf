#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_addParachuteToObject

Description:
    Spawns a cargo parachute at an object's position. With _attach true (the
    default) the object is slung under it and handed to
    ghostD_common_fnc_ensureSafeLanding; with false the chute is returned bare,
    for callers building a multi-chute rig.

Parameters:
    _object : OBJECT - object to drop.
    _attach : BOOL   - attach the object and manage the landing. (default: true)

Returns:
    OBJECT - the created parachute.

Author:
    Mr H. (original, MRHMilsimTools, ADPL-SA), ported by Ghost
---------------------------------------------------------------------------- */
params ["_object", ["_attach", true, [true]]];

private _chute = "O_Parachute_02_F" createVehicle (position _object);
_chute setPosATL (getPosATL _object);

if (_attach) then {
    _object attachTo [_chute, [0, 0, 0]];
    [_object] call FUNC(ensureSafeLanding);
};

_chute
