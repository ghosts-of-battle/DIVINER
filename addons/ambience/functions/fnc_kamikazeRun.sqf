#include "script_component.hpp"
/*
 * Author: Ghost
 * One kamikaze run: a real drone appears a few hundred metres out, flies a
 * straight dive at the building and detonates on arrival.
 *
 * REAL AND KILLABLE, which is the whole point of doing this with an
 * aircraft instead of a spawned explosion: it is heard coming, it can be
 * seen against the sky, and anything that shoots it down has genuinely
 * stopped the strike - a dead drone detonates nothing. Steering is a
 * velocity write per tick, the missile treatment - the UAV's own AI never
 * gets a vote on where it is going.
 *
 * The spawn point is gated like every module spawn: re-rolled until it is
 * inside the module's markers, and the run is skipped when no bearing is -
 * the war stays inside the line even while approaching from outside would
 * be prettier.
 *
 * Arguments:
 * 0: Building position ATL <ARRAY>
 * 1: Drone classname <STRING>
 * 2: Speed in m/s <NUMBER>
 * 3: The module's markers, for the spawn gate <ARRAY>
 *
 * Return Value:
 * The run is airborne <BOOL>
 *
 * Public: No
 */

params [["_tgt", [], [[]]], ["_cls", "", [""]], ["_speed", 40, [0]], ["_markers", [], [[]]]];

if (_tgt isEqualTo [] || _cls isEqualTo "") exitWith {false};

// A few hundred metres out on a random bearing, high enough to be seen.
// Re-rolled against the gate; no compliant bearing, no run.
private _from = [];
for "_i" from 1 to 8 do {
    private _try = _tgt getPos [350 + random 250, random 360];
    if ([sideUnknown, _try, "ambient kamikaze spawn", _markers] call EFUNC(common,taorGate)) exitWith {
        _from = _try;
    };
};
if (_from isEqualTo []) exitWith {
    INFO("kamikaze run skipped - no spawn bearing inside the markers");
    false
};
_from set [2, 120 + random 60];

private _veh = createVehicle [_cls, _from, [], 0, "FLY"];
if (isNull _veh) exitWith {false};
_veh setPosATL _from;
createVehicleCrew _veh;
(group _veh) deleteGroupWhenEmpty true;

// The run is a straight dive on a steering loop - LAMBS taking an interest
// in it would only fight the velocity writes.
[_veh] call EFUNC(common,lambsOff);

// The neighbourhood hears the motor before the dive.
["FPV", "One-way drone inbound", _tgt, 400, 2] call EFUNC(common,alert);
INFO_2("kamikaze away: %1 -> grid %2",_cls,mapGridPosition _tgt);

// Aim just above the ground floor so the dive terminates on the walls,
// not the roof line's far side.
private _aim = +_tgt;
_aim set [2, 2];

[{
    params ["_args", "_handle"];
    _args params ["_veh", "_aim", "_speed", "_until"];

    // Shot down or fell apart: the strike died with it - that is the
    // counterplay paying out. Nothing detonates.
    if (isNull _veh || {!alive _veh}) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    if (CBA_missionTime > _until) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        deleteVehicle _veh;
    };

    private _here = getPosATL _veh;
    if (_here distance _aim < AMB_KAM_FUSE) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        private _at = getPosATL _veh;
        deleteVehicle _veh;
        createVehicle ["Sh_122mm_AMOS", _at, [], 0, "CAN_COLLIDE"];
    };

    _veh setVelocity ((_here vectorFromTo _aim) vectorMultiply _speed);
    _veh setVectorDir (_here vectorFromTo _aim);
}, AMB_KAM_STEP, [_veh, _aim, _speed, CBA_missionTime + AMB_KAM_TIMEOUT]] call CBA_fnc_addPerFrameHandler;

true
