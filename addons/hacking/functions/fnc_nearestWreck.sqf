#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_nearestWreck

Description:
    Nearest downed drone worth stripping. A UAV that has been shot out of the sky
    is still a box full of somebody's data, and walking up to a wreck to pull it
    is a different job from reaching a live one at 400 m - so this is close range,
    like a tower, and the reward is intel rather than a takedown.

    Uses nearestObjects rather than nearEntities on purpose: nearEntities skips
    the dead, which is the entire population this function is looking for.

    Side is checked only when it can still be answered. A wreck's crew is usually
    gone, so its group resolves to nothing; rather than let that silently exclude
    every wreck, an unknown side is treated as fair game. You cannot tell whose
    airframe it was by looking at it either.

    Honours the same GVAR(droneClasses) filter as the live-drone scan, so a
    mission that narrows what may be hacked narrows both.

Parameters:
    _unit : OBJECT - the player.

Returns:
    OBJECT - nearest strippable wreck, or objNull.

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_unit"];

private _mySide = side group _unit;
private _allowed = (GVAR(droneClasses) splitString ", ") select { _x != "" };

// Sorted nearest first, so the first match is the answer.
private _cands = nearestObjects [_unit, ["Air", "LandVehicle"], HACK_WRECK_RANGE];

private _best = objNull;
{
    // named, so the class-list findIf below does not shadow it with its own _x
    private _veh = _x;
    private _side = side group _veh;
    if (
        !alive _veh
        && {getNumber (configOf _veh >> "isUav") > 0}
        && {!(_veh getVariable [QGVAR(stripped), false])}
        && {!(_side in [_mySide, sideFriendly]) }
        && {_allowed isEqualTo [] || {_allowed findIf {_veh isKindOf _x} > -1}}
    ) exitWith { _best = _veh };
} forEach _cands;

_best
