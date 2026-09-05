#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_towersInRange

Description:
    Every hackable tower near a unit, rather than just the nearest one the old
    ACE action needed. Same two sources as FUNC(nearestTower): the configured
    tower classnames, plus any live Electronic War Zones emitter.

Parameters:
    _unit  : OBJECT - the operator.
    _range : NUMBER - metres.

Returns:
    ARRAY - of OBJECT.

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_unit", ["_range", 50, [0]]];

private _classes = (GVAR(towerClasses) splitString ", ") select { _x != "" };
private _out = [];
if (_classes isNotEqualTo []) then {
    _out = nearestObjects [_unit, _classes, _range];
};

// and anything tagged a pop - see FUNC(nearestTower) for why the tag beats
// the classname list
{
    if (_x getVariable [QEGVAR(leaders,pop), false]) then { _out pushBackUnique _x };
} forEach (nearestObjects [_unit, [], _range]);

// AND THE EW EMITTERS. The registry moved when electronic_war_zones became
// jamming, and this read was dropped instead of renamed - which left every
// emitter standing as furniture nobody could plug into. An abstract zone has
// no object and nothing to stand next to.
{
    private _o = _x param [0, objNull];
    if (!isNull _o && {(_unit distance _o) <= _range}) then { _out pushBackUnique _o };
} forEach (missionNamespace getVariable [QEGVAR(jamming,jammers), []]);

// The TAOR gate last: every tower inside the TAOR is hackable, none outside.
_out select { alive _x && {[_x] call FUNC(towerInTaor)} }
