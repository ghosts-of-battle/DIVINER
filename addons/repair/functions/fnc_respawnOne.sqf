#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_repair_fnc_respawnOne

Description:
    Rebuilds one destroyed charge from the snapshot taken at mission start.

    The wreck is removed first. Creating the replacement on top of a wreck leaves
    two objects fighting for the same ground, and Arma resolves that by throwing
    one of them into the air.

    What comes back is a NEW object. It has the class, the place and the facing
    of the original, and a crew if the original had one - but not its name, its
    variables, its loadout edits, or any event handlers a mission script attached
    to it. Anything that has to survive a respawn belongs on the module or in a
    script keyed to position, not on the object.

Parameters:
    _record : ARRAY   - the charge's record.
    _cfg    : HASHMAP - the module's settings.

Returns:
    OBJECT - the replacement, objNull on failure.

Author:
    Ghost
---------------------------------------------------------------------------- */
if (!isServer) exitWith { objNull };

params ["_record", "_cfg"];
_record params ["_old", "_class", "_pos", "_dir", "_up", "_wasCrewed"];

if (_class isEqualTo "") exitWith { objNull };

if (!isNull _old) then {
    { deleteVehicle _x } forEach (crew _old);
    deleteVehicle _old;
};

private _new = createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"];
if (isNull _new) exitWith {
    diag_log text format ["[ghost_repair] could not respawn '%1'", _class];
    objNull
};

_new setDir _dir;
_new setPosATL _pos;
_new setVectorUp _up;

// Only if it started crewed. Respawning an empty truck with a driver in it is
// not a repair, it is a reinforcement nobody asked for.
if (_wasCrewed) then {
    private _grp = createVehicleCrew _new;
    if ((units _grp) isEqualTo []) then { deleteGroup _grp };
};

if (_cfg get "debug") then {
    diag_log text format ["[ghost_repair] respawned %1 at grid %2", _class, mapGridPosition _pos];
};

_new
