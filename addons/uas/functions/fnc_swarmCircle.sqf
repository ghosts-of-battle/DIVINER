#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_uas_fnc_swarmCircle

Description:
    One drone of a circling swarm: spawned on the ring, given a loiter waypoint,
    and then left alone.

    IT IS LEFT ALONE ON PURPOSE. An impact drone is flown by a steering loop
    because it is a weapon with no opinion; a circling one has a crew, sensors
    and usually a gun, and what it does with a target it finds is its own
    business. Writing its velocity would fight the very AI that makes it worth
    fielding - so this puts it on station and stops.

    THEY FLY IN. Each spawns out at the module's spawn band and the LOITER
    waypoint brings it to the ring - a swarm appearing already on station is one
    nobody got to hear coming.

    SPACED AROUND THE RING, not stacked. Each drone takes its own slice of the
    circle from its index, so eight of them are eight bearings rather than eight
    aircraft in one spot arguing about the same piece of air. Altitude is
    staggered with it, because a stack that shares one height is a stack that
    collides.

    NO STAND-DOWN AND NO REPLACEMENT. A swarm is an event, not a presence: what
    is launched is what there is, and when it is dead it is dead. That is
    FUNC(moduleDronePatrol)'s job and the reason the two modules are separate.

Parameters:
    0: Airframe class <STRING>
    1: Side <SIDE>
    2: Centre position ATL <ARRAY>
    3: Orbit radius <NUMBER>
    4: This drone's index in the swarm <NUMBER>
    5: How many in the swarm <NUMBER>
    6: Nearest it may spawn, m <NUMBER>
    7: Furthest it may spawn, m <NUMBER>

Returns:
    Whether it got airborne <BOOL>

Author:
    YonV
---------------------------------------------------------------------------- */
params [["_class", "", [""]], ["_side", east, [east]], ["_centre", [], [[]]],
        ["_radius", 400, [0]], ["_index", 0, [0]], ["_count", 1, [0]],
        ["_min", UAS_SWARM_SPAWN_MIN, [0]], ["_max", UAS_SWARM_SPAWN_MAX, [0]]];

if (!isServer) exitWith {false};
if (_class isEqualTo "" || {_centre isEqualTo []}) exitWith {false};

// Its own slice of the ring, and its own shelf.
private _bearing = (360 / (_count max 1)) * _index;
private _alt = UAS_SWARM_ALT + (_index % 3) * UAS_SWARM_ALT_STEP;

// IT ARRIVES, IT DOES NOT APPEAR. Spawned out at the module's band on its own
// bearing and flown in by the LOITER waypoint below - a swarm that materialises
// already on station gives nobody the chance to hear it coming. The bearing is
// the slice it will hold on the ring, so the transit spreads them out as well.
private _at = _centre getPos [_min + random ((_max - _min) max 0), _bearing];
_at set [2, _alt];

private _veh = createVehicle [_class, _at, [], 0, "FLY"];
if (isNull _veh) exitWith {false};

_veh setPosATL _at;
createVehicleCrew _veh;

// THE UAV AI STAYS IN ITS OWN CREW GROUP, and the side is NOT forced onto it.
// FUNC(topUp) learned this the hard way: a UAV's autonomy lives in the crew
// group createVehicleCrew makes, and joining that AI into a group of our own
// leaves an aircraft with nobody flying it - drones fell out of the sky.
//
// So the airframe's own config decides the side, which is why the picker and
// the Side field want to agree. The field is the fallback crew's side for the
// case below, where an airframe - a modded one especially - comes out of
// createVehicleCrew empty on a dedicated server.
if ((crew _veh) isEqualTo []) then {
    private _ai = switch (_side) do {
        case west: {"B_UAV_AI"};
        case independent: {"I_UAV_AI"};
        default {"O_UAV_AI"};
    };
    private _own = getText (configOf _veh >> "crew");
    if (_own isNotEqualTo "" && {isClass (configFile >> "CfgVehicles" >> _own)}) then { _ai = _own };

    private _crewGrp = createGroup [_side, true];
    _crewGrp deleteGroupWhenEmpty true;
    (_crewGrp createUnit [_ai, getPosATL _veh, [], 0, "NONE"]) moveInAny _veh;
};

(group _veh) deleteGroupWhenEmpty true;

_veh flyInHeight _alt;

// LOITER, which is the engine's own orbit and holds the radius properly. A
// MOVE waypoint on a circle centre is an aircraft that arrives and then wanders
// off looking for something to do.
// The waypoint goes on the CREW's group, which is the one actually flying the
// aircraft - see the crewing note above.
private _wp = (group _veh) addWaypoint [_centre, 0];
_wp setWaypointType "LOITER";
_wp setWaypointLoiterType "CIRCLE";
_wp setWaypointLoiterRadius _radius;
_wp setWaypointBehaviour "COMBAT";
_wp setWaypointCombatMode "RED";
_wp setWaypointSpeed "NORMAL";

true
