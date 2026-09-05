#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_jamming_fnc_gpsDrift

Description:
    Walks the GPS sphere across the map, and takes it down when its uplink dies.
    Server only. Started once per sphere by FUNC(spawnGpsUplink) and reschedules
    itself until the sphere is gone.

    IT MOVES, AND THAT IS THE POINT. A static GPS field is a place you learn and
    then route around. A wandering one is weather: it arrives, the map stops
    telling you where you are, and it leaves - and the only way to stop it
    happening again is to find the uplink steering it.

    A RANDOM WALK, NOT A PATROL. The heading holds for several ticks and then
    re-rolls, so the sphere drifts rather than jittering, and nobody can read a
    pattern off two crossings. It turns at the world edge instead of clamping,
    because a sphere that parks on the coastline is a static field again.

    IT IS MOVED ON THE SERVER AND PUBLISHED, not computed live on each client
    from a seed. The registry is a few dozen entries and this fires once every
    GPS_DRIFT_TICK seconds; a deterministic position would save a broadcast that
    costs nothing and would put a second copy of the movement rule in
    FUNC(jamFactor), where every consumer would then have to agree with it.

Parameters:
    _id : STRING - the sphere's zone id.

Returns:
    Nothing.

Author:
    Ghost
---------------------------------------------------------------------------- */
if (!isServer) exitWith {};

params [["_id", "", [""]]];
if (_id isEqualTo "") exitWith {};

private _idx = GVAR(jammers) findIf { (_x param [ZONE_ID, ""]) isEqualTo _id };
if (_idx < 0) exitWith {};   // already gone; nothing to reschedule

private _zone = GVAR(jammers) select _idx;
private _model = _zone param [ZONE_MODEL, createHashMap];

// --- has the uplink been taken? ---------------------------------------------
// The sphere is held up by a zone, not by an object, so this asks the registry
// rather than the world: FUNC(pruneJammers) already removes an uplink that has
// been destroyed OR hacked, so its absence is the one condition to test and
// both ways of ending it are covered by the one check.
private _held = _model getOrDefault ["heldBy", ""];
if (_held isNotEqualTo ""
    && {(GVAR(jammers) findIf { (_x param [ZONE_ID, ""]) isEqualTo _held }) < 0}) exitWith {
    GVAR(jammers) = GVAR(jammers) select { (_x param [ZONE_ID, ""]) isNotEqualTo _id };
    [] call FUNC(publishZones);
    INFO_1("GPS denial down: uplink gone, sphere %1 removed",_id);
};

// --- drift ------------------------------------------------------------------
private _dir = _model getOrDefault ["driftDir", random 360];
if (random 100 < GPS_TURN_CHANCE) then { _dir = random 360 };

private _pos = _zone param [ZONE_POS, [0,0,0]];
private _step = GPS_DRIFT_SPEED * GPS_DRIFT_TICK;
private _next = _pos vectorAdd [_step * sin _dir, _step * cos _dir, 0];

// Turn at the edge rather than clamp. A clamped sphere slides along the border
// and stops being weather; reversing sends it back over the map.
private _world = worldSize;
if ((_next select 0) < GPS_EDGE_MARGIN || {(_next select 0) > (_world - GPS_EDGE_MARGIN)}
    || {(_next select 1) < GPS_EDGE_MARGIN} || {(_next select 1) > (_world - GPS_EDGE_MARGIN)}) then {
    _dir = (_dir + 180) % 360;
    _next = _pos vectorAdd [_step * sin _dir, _step * cos _dir, 0];
};

_model set ["driftDir", _dir];
_zone set [ZONE_POS, _next];
GVAR(jammers) set [_idx, _zone];
[] call FUNC(publishZones);

TRACE_2("GPS sphere drifted",_id,mapGridPosition _next);

[FUNC(gpsDrift), [_id], GPS_DRIFT_TICK] call CBA_fnc_waitAndExecute;
