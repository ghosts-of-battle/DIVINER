#include "script_component.hpp"
/*
 * Author: Ghost
 * One incoming round against one vehicle's launchers - Drongo's engagement,
 * kept whole (SCHEDULED, it sleeps): a beat to see the round is really
 * coming in, the approach angle (a top-attack dive is immune), the round's
 * size, the sector it arrives from (its own charges, and the front half only
 * for a BASIC fit), then a wait until it is APS_KILL_RANGE out and the
 * round dies with a flash. A tank round on the enhanced fit is killed on
 * sight instead - there is no flying out to it.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Projectile <OBJECT>
 * 2: A tank round (shell) <BOOL>
 *
 * Return Value: None
 *
 * Public: No
 */

params ["_veh", "_p", ["_shell", false]];
if (isNull _p || {isNull _veh}) exitWith {};
if ((typeOf _p) in GVAR(blacklist)) exitWith {};

private _fit = _veh getVariable [QGVAR(fit), FIT_NONE];
if (_fit isEqualTo FIT_NONE) exitWith {};
(GVAR(fits) get _fit) params ["", "_range", "", "", "_frontOnly"];

private _d = _veh distance _p;
if (!_shell && _d < APS_KILL_RANGE) exitWith {};   // already inside the kill range - too late

sleep 0.1;
if (isNull _p || {!alive _veh}) exitWith {};
if ((_veh distance _p) > _d) exitWith {};             // going away

// the approach angle: a round diving steeper than the setting is above the launchers
private _vPos = getPosASL _veh;
private _pPos = getPosASL _p;
private _alt = (_pPos select 2) - (_vPos select 2);
if (_alt > 0) then {
    private _flat = _vPos distance2D _pPos;
    if (_flat > 0 && {atan (_alt / _flat) > GVAR(maxAngle)}) exitWith {};
};
if (getNumber (configOf _p >> "hit") > GVAR(hitLimit)) exitWith {};

// the sector, from the turret's facing - the direction the round comes FROM
private _facing = getDir _veh;
private _turrets = allTurrets [_veh, false];
if (_turrets isNotEqualTo []) then {
    private _w = (_veh weaponsTurret (_turrets select 0)) param [0, ""];
    if (_w isNotEqualTo "") then {
        private _wd = _veh weaponDirection _w;
        _facing = ((_wd select 0) atan2 (_wd select 1)) mod 360;
        if (_facing < 0) then { _facing = _facing + 360 };
    };
};
private _rel = ((getDir _p) + 180 - _facing) mod 360;
if (_rel < 0) then { _rel = _rel + 360 };
if (_frontOnly && {_rel > 90 && _rel < 270}) exitWith {};
private _pool = [QGVAR(ammoR), QGVAR(ammoL)] select (_rel > 180);
if ((_veh getVariable [_pool, 0]) < 1) exitWith {};

// the crew reacts: combat, eyes on it, smoke from whoever owns the vehicle
(group _veh) setBehaviour "COMBAT";
{ _x doWatch _pPos } forEach crew _veh;
[_veh] remoteExec [QFUNC(popSmoke), _veh];

private _blast = {
    params ["_at"];   // ATL
    createVehicle [QGVAR(blast), _at, [], 0, "CAN_COLLIDE"];
};
private _spend = {
    _veh setVariable [_pool, ((_veh getVariable [_pool, 0]) - 1) max 0, true];
    [_veh, _rel, "INTERCEPT"] remoteExec [QFUNC(report), [0, -2] select isDedicatedServer];
    if (GVAR(debug)) then { INFO_3("%1 killed %2 from %3 deg",typeOf _veh,typeOf _p,round _rel) };
};

if (_shell) exitWith {
    // on sight: the flash five metres out on the round's bearing
    deleteVehicle _p;
    [_veh getPos [5, (_rel + _facing) mod 360]] call _blast;
    call _spend;
};

// out to meet it
private _ok = true;
while {true} do {
    if (isNull _p || {!alive _p}) exitWith { _ok = false };
    if (!alive _veh) exitWith { _ok = false };
    _d = _veh distance _p;
    if (_d > _range + 1) exitWith { _ok = false };
    if (_d < APS_KILL_RANGE) exitWith {};
    sleep 0.001;
};
if (!_ok) exitWith {};
private _at = getPosATL _p;
deleteVehicle _p;
[_at] call _blast;
call _spend;
