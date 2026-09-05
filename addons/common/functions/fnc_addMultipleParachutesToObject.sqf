#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_addMultipleParachutesToObject

Description:
    Drops an object under a chute rig sized to its mass. Everything gets one
    lead chute; anything over 4 t gets extras attached around the lead so they
    splay out — 1 extra under 10 t, rising to 4 at 30 t and above. Landing is
    handled by ghostD_common_fnc_ensureSafeLanding.

Parameters:
    _object : OBJECT - object to drop.

Returns:
    Nothing.

Example:
    cursorTarget setPosATL ((getPosATL cursorTarget) vectorAdd [0, 0, 100]);
    [cursorTarget] call ghostD_common_fnc_addMultipleParachutesToObject;

Author:
    Mr H. (original, MRHMilsimTools, ADPL-SA), ported by Ghost
---------------------------------------------------------------------------- */
params ["_object"];

private _lead = [_object] call FUNC(addParachuteToObject);

private _mass = getMass _object;
if (_mass < 4000) exitWith {};

private _count = switch (true) do {
    case (_mass < 10000): {0};
    case (_mass < 20000): {1};
    case (_mass < 30000): {2};
    default {3};
};

private _offsets = [[0.5, 0.4, 0.6], [-0.5, 0.4, 0.6], [0.5, -0.4, 0.6], [-0.5, -0.4, 0.6]];

for "_i" from 0 to _count do {
    private _chute = [_object, false] call FUNC(addParachuteToObject);
    _chute setDir (getDir _object);
    _chute attachTo [_lead, [0, 0, 0]];
    _chute setVectorUp (_offsets select _i);
};

[_object] call FUNC(ensureSafeLanding);
