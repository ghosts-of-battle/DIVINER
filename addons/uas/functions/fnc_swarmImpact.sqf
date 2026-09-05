#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_uas_fnc_swarmImpact

Description:
    One drone of an impact swarm: spawned off the target, flown into it, gone.

    THE SAME DIVE THE AMBIENT KAMIKAZE FLIES, deliberately - a straight steering
    loop that writes velocity at the aim point every step, LAMBS turned off on
    the airframe because an AI taking an interest in it would only fight those
    writes. It is written here rather than called from `ambience` because that
    function picks its own target near a player and gates the spawn on a
    module's markers; a swarm has been told where to go.

    SHOT DOWN IS THE COUNTERPLAY AND IT PAYS OUT. A drone that dies on the way
    in detonates nothing - the handler removes itself and that is one fewer
    warhead arriving. That is the whole reason a swarm is a fight rather than an
    announcement, and why the count on the module matters.

    A SPREAD OF BEARINGS AND DISTANCES, not a queue. Each drone comes from its
    own rolled direction and its own distance inside the module's band, so a
    swarm arrives as a swarm rather than as a line of aircraft down one axis
    that one gunner can work along.

    IT GIVES UP. UAS_SWARM_TIMEOUT and the airframe deletes itself - a drone
    that lost its aim to terrain and is circling a hillside forever is a leak.

Parameters:
    0: Airframe class <STRING>
    1: Side <SIDE>
    2: Target position ATL <ARRAY>
    3: Nearest it may spawn, m <NUMBER>
    4: Furthest it may spawn, m <NUMBER>

Returns:
    Whether it got airborne <BOOL>

Author:
    YonV
---------------------------------------------------------------------------- */
params [["_class", "", [""]], ["_side", east, [east]], ["_tgt", [], [[]]],
        ["_min", UAS_SWARM_SPAWN_MIN, [0]], ["_max", UAS_SWARM_SPAWN_MAX, [0]]];

if (!isServer) exitWith {false};
if (_class isEqualTo "" || {_tgt isEqualTo []}) exitWith {false};

// FAR ENOUGH TO BE FOUGHT. Each drone rolls its own distance inside the band and
// its own bearing, so a swarm arrives spread rather than as a line down one axis
// a single gunner can work along - and the transit is the window in which it can
// be shot at. At UAS_SWARM_SPEED, 1500 m is about thirty seconds of somebody
// deciding what to do about it.
private _from = _tgt getPos [_min + random ((_max - _min) max 0), random 360];
_from set [2, 100 + random 80];

private _veh = createVehicle [_class, _from, [], 0, "FLY"];
if (isNull _veh) exitWith {false};

_veh setPosATL _from;
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

[_veh] call EFUNC(common,lambsOff);

// Aimed just off the deck so the dive terminates on what is standing there
// rather than sailing over the far side of a roof line.
private _aim = +_tgt;
_aim set [2, 2];

[{
    params ["_args", "_handle"];
    _args params ["_veh", "_aim", "_until"];

    // Shot down or fell apart. Nothing detonates - that is the counterplay.
    if (isNull _veh || {!alive _veh}) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    if (CBA_missionTime > _until) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        deleteVehicle _veh;
    };

    private _here = getPosATL _veh;

    if (_here distance _aim < UAS_SWARM_FUSE) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        private _boom = getPosATL _veh;
        deleteVehicle _veh;
        createVehicle [UAS_SWARM_WARHEAD, _boom, [], 0, "CAN_COLLIDE"];
    };

    _veh setVelocity ((_here vectorFromTo _aim) vectorMultiply UAS_SWARM_SPEED);
    _veh setVectorDir (_here vectorFromTo _aim);
}, UAS_SWARM_STEP, [_veh, _aim, CBA_missionTime + UAS_SWARM_TIMEOUT]] call CBA_fnc_addPerFrameHandler;

true
