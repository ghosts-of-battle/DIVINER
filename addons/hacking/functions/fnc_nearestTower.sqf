#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_nearestTower

Description:
    Nearest hackable "tower" within HACK_TOWER_RANGE: any object whose class
    is in the GVAR(towerClasses) setting, anything tagged an internet pop, and
    any live EW emitter out of the jamming registry. Skips already-hacked and
    dead objects.

Parameters:
    _unit : OBJECT - the player.

Returns:
    OBJECT - nearest hackable tower, or objNull.

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_unit"];

// classname-configured towers
private _classes = (GVAR(towerClasses) splitString ", ") select { _x != "" };
private _cands = [];
if (_classes isNotEqualTo []) then {
    _cands = nearestObjects [_unit, _classes, HACK_TOWER_RANGE];
};

// AND ANYTHING TAGGED A POP. The internet pops are hackable because they are
// pops, not because of what they are made of - the mission picks that prop,
// and a classname list is a second place to remember it. They were placed
// for months as furniture nobody could plug into because their class was
// never in the list above.
{
    if (_x getVariable [QEGVAR(leaders,pop), false]) then { _cands pushBackUnique _x };
} forEach (nearestObjects [_unit, [], HACK_TOWER_RANGE]);

// EW emitters, from the jamming registry - see FUNC(towersInRange).
{
    private _o = _x param [0, objNull];
    if (!isNull _o && {(_unit distance _o) <= HACK_TOWER_RANGE}) then { _cands pushBackUnique _o };
} forEach (missionNamespace getVariable [QEGVAR(jamming,jammers), []]);

private _best = objNull;
private _bestDist = HACK_TOWER_RANGE + 1;
{
    if (
        !isNull _x && {alive _x}
        && {!(_x getVariable [QGVAR(hacked), false])}
        // every tower inside the TAOR is hackable, none outside
        && {[_x] call FUNC(towerInTaor)}
    ) then {
        private _d = _unit distance _x;
        if (_d < _bestDist) then { _bestDist = _d; _best = _x };
    };
} forEach _cands;

_best
