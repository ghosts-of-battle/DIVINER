#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_antiship_fnc_fly

Description:
    Flies a Burevestnik: climb, sea-skimming cruise, terminal dive.

    The three phases exist because a missile that simply points at the ship from
    launch flies a lazy arc across the sky in full view for its whole flight.
    Cruising low is what makes the thing a problem - it appears late, from a
    direction nobody was watching, and the defence gets seconds rather than
    minutes.

    Terminal guidance is proportional navigation, steering to null the rotation
    of the line of sight rather than to point at the hull. A ship under way is a
    moving target, and pointing at where it is puts you behind it.

    It watches its own decoy. When the decoy is hit, the missile is destroyed
    where it stands - the intercept, credited to whoever shot it.

Parameters:
    _missile : OBJECT  - the round.
    _tgt     : OBJECT  - the hull.
    _cfg     : HASHMAP - the battery's settings.
    _decoy   : OBJECT  - its decoy, objNull if the battery is unstoppable.

Author:
    Ghost
---------------------------------------------------------------------------- */
if (!isServer) exitWith {};

params ["_missile", "_tgt", "_cfg", ["_decoy", objNull, [objNull]]];

private _boostUntil = CBA_missionTime + AS_BOOST_TIME;
private _until = CBA_missionTime + AS_TIMEOUT;

[{
    params ["_args", "_handle"];
    _args params ["_missile", "_tgt", "_cfg", "_decoy", "_boostUntil", "_until"];

    private _stop = {
        if (!isNull _decoy) then {
            { deleteVehicle _x } forEach (crew _decoy);
            deleteVehicle _decoy;
        };
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    if (isNull _missile) exitWith { call _stop };

    // Target gone, or it has been in the air far too long.
    if (isNull _tgt || CBA_missionTime > _until) exitWith {
        deleteVehicle _missile;
        call _stop;
    };

    // --- shot down ----------------------------------------------------------
    if (!isNull _decoy && {damage _decoy > 0.1}) exitWith {
        if (_cfg get "debug") then {
            diag_log text format ["[ghostD_antiship] INTERCEPTED at grid %1",
                mapGridPosition (getPosATL _missile)];
        };
        // Its own warhead, in the air, where it was caught.
        triggerAmmo _missile;
        call _stop;
    };

    private _speed = _cfg get "speed";
    private _mPos = getPosASL _missile;
    private _tPos = getPosASL _tgt;
    private _dist = _mPos distance2D _tPos;

    // --- arrived ------------------------------------------------------------
    if ((_mPos vectorDistance _tPos) <= AS_FUZE) exitWith {
        if (_cfg get "debug") then {
            diag_log text format ["[ghostD_antiship] HIT %1", typeOf _tgt];
        };
        triggerAmmo _missile;
        call _stop;
    };

    // --- climb --------------------------------------------------------------
    // Straight up first. A missile that starts steering at launch speed from a
    // standing start just tips over into the sea.
    if (CBA_missionTime < _boostUntil) exitWith {
        _missile setVelocity [0, 0, _speed * 0.4];
    };

    private _aim = _tPos;

    // --- cruise -------------------------------------------------------------
    // Outside terminal range it flies AT the target's bearing but at cruise
    // height, so the run in is low and flat rather than a descending arc.
    if (_dist > (_cfg get "terminal")) then {
        _aim = [
            _tPos select 0,
            _tPos select 1,
            ((getTerrainHeightASL [_mPos select 0, _mPos select 1]) max 0) + (_cfg get "cruiseAlt")
        ];
    };

    // --- proportional navigation --------------------------------------------
    private _mVel = velocity _missile;
    private _los = _aim vectorDiff _mPos;
    private _losSq = _los vectorDotProduct _los;
    if (_losSq <= 0) exitWith { call _stop };

    private _relVel = (velocity _tgt) vectorDiff _mVel;
    private _omega = (_los vectorCrossProduct _relVel) vectorMultiply (1 / _losSq);
    private _acc = (_relVel vectorMultiply AS_PN_GAIN) vectorCrossProduct _omega;

    private _new = _mVel vectorAdd (_acc vectorMultiply AS_TICK_FLY);

    // Pure PN can be lazy at long range where the bearing barely moves, so the
    // steering is blended with a direct heading. Without it a sea-skimmer will
    // happily cruise past the ship and turn round.
    private _steer = _mPos vectorFromTo _aim;
    _new = (vectorNormalized _new) vectorAdd (_steer vectorMultiply 0.35);
    _new = (vectorNormalized _new) vectorMultiply _speed;

    _missile setVectorDir _new;
    _missile setVelocity _new;
}, AS_TICK_FLY, [_missile, _tgt, _cfg, _decoy, _boostUntil, _until]] call CBA_fnc_addPerFrameHandler;
