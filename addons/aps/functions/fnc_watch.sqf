#include "script_component.hpp"
/*
 * Author: Ghost
 * One fitted vehicle's watch, every APS_TICK on the server: the launchers
 * look for incoming rounds and hand each new one to fnc_intercept; the
 * emitter looks for a threat every APS_RF_TICK and fires fnc_burst; a
 * rearm is looked for every rearm delay.
 *
 * Arguments:
 * 0: Arguments <ARRAY> - [vehicle]
 * 1: Handler id <NUMBER>
 *
 * Return Value: None
 *
 * Public: No
 */

params ["_args", "_handle"];
_args params ["_veh"];

if (!alive _veh) exitWith {
    [_handle] call CBA_fnc_removePerFrameHandler;
    _veh setVariable [QGVAR(pfh), nil];
};

private _now = CBA_missionTime;
private _crewed = (crew _veh) isNotEqualTo [];
private _engine = isEngineOn _veh;

// ---- the launchers -------------------------------------------------------
// HK HOLD is the crew's word that the launchers stay quiet - set from the map
// panel (fnc_setHold), read here every tick
private _fit = _veh getVariable [QGVAR(fit), FIT_NONE];
if (_fit isNotEqualTo FIT_NONE && _crewed && _engine && {([_veh] call FUNC(charges)) > 0}
        && {!(_veh getVariable [QGVAR(hkHold), false])}) then {
    (GVAR(fits) get _fit) params ["", "_range", "_families", "_shells", ""];
    private _seen = _veh getVariable [QGVAR(seen), []];
    private _incoming = [];
    {
        _incoming append (_veh nearObjects [_x, _range]);
    } forEach _families;
    private _shellsIn = [];
    if (_shells) then {
        _shellsIn = _veh nearObjects ["ShellCore", APS_SHELL_RANGE];
        _incoming append _shellsIn;
    };
    _incoming = _incoming select { !(_x in _seen) && {!((typeOf _x) in GVAR(blacklist))} };
    // two per tick, as DAPS does - a volley is dealt with over a few ticks
    {
        if (_forEachIndex > 1) exitWith {};
        _seen pushBack _x;
        [_veh, _x, _x in _shellsIn] spawn FUNC(intercept);
    } forEach _incoming;
    _veh setVariable [QGVAR(seen), _seen];
};

// ---- the emitter -----------------------------------------------------------
if (_veh getVariable [QGVAR(rf), false]) then {
    if (_now >= (_veh getVariable [QGVAR(rfTick), 0])) then {
        _veh setVariable [QGVAR(rfTick), _now + APS_RF_TICK];
        // RF HOLD stops the emitter firing on its OWN; a manual BURST from the
        // panel (fnc_burstNow) still goes
        private _live = _crewed && _engine && {_now >= (_veh getVariable [QGVAR(rfReady), 0])}
            && {damage _veh < GVAR(rfDamage)} && {(_veh getHitPointDamage "HitEngine") < 0.9}
            && {!(_veh getVariable [QGVAR(rfHold), false])};
        if (_live) then {
            private _pos = getPosASL _veh;
            private _closing = {
                params ["_c"];
                (_c distance _veh) <= GVAR(rfFloor)
                || {((velocity _c) vectorDotProduct (vectorNormalized (_pos vectorDiff (getPosASL _c)))) > GVAR(rfClosing)}
            };
            private _threat = false;
            // guided munitions on their way in
            {
                if (_threat) exitWith {};
                {
                    if (([_x] call FUNC(isGuided)) isNotEqualTo "" && {[_x] call _closing}) exitWith { _threat = true };
                } forEach (_veh nearObjects [_x, GVAR(rfRadius)]);
            } forEach ["MissileCore", "RocketCore"];
            // hostile drones closing
            if (!_threat) then {
                private _mine = side (group _veh);
                {
                    if (getNumber (configOf _x >> "isUav") > 0 && {(side _x) getFriend _mine < 0.6} && {[_x] call _closing}) exitWith { _threat = true };
                } forEach (_veh nearEntities [["Air"], GVAR(rfRadius)]);
            };
            if (_threat) then { [_veh] call FUNC(burst) };
        };
    };
};

// ---- the rearm ---------------------------------------------------------------
if (_now >= (_veh getVariable [QGVAR(nextRearm), 0])) then {
    _veh setVariable [QGVAR(nextRearm), _now + GVAR(rearmDelay)];
    _veh setVariable [QGVAR(seen), (_veh getVariable [QGVAR(seen), []]) select { !isNull _x }];
    if (_fit isNotEqualTo FIT_NONE) then {
        // the guns were reloaded (the count went up), or a supply is at hand
        private _gun = 0;
        { _gun = _gun + (_x select 2) } forEach magazinesAllTurrets _veh;
        private _last = _veh getVariable [QGVAR(lastAmmo), _gun];
        private _reloaded = _gun > _last;
        _veh setVariable [QGVAR(lastAmmo), _gun];
        if (!_reloaded && {([_veh] call FUNC(charges)) < 2 * (_veh getVariable [QGVAR(ammoMax), 0])}) then {
            _reloaded = (nearestObjects [_veh, ["LandVehicle", "ReammoBox_F"], GVAR(rearmRange)]) findIf {
                getNumber (configOf _x >> "transportAmmo") > 0
                || {getNumber (configOf _x >> "ace_rearm_defaultSupply") > 0}
                || {_x getVariable ["ace_rearm_isSupplyVehicle", false]}
            } > -1;
        };
        if (_reloaded) then { [_veh] call FUNC(rearm) };
    };
};
