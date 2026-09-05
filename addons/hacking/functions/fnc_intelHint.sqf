#include "script_component.hpp"
/*
 * Author: Ghost
 * ISR processed a batch: one circle on the nearest piece of the enemy's
 * network.
 *
 * THE POOL IS WHAT IS ON THE MAP. Anti-ship batteries and their radars,
 * ghost's own air defence sites, the drone supply caches, and the safe houses
 * if the leaders addon is loaded. Whatever is hostile to the depositing side
 * and still standing is a candidate.
 *
 * IT USED TO BE HALF ALiVE'S. Its air defence, artillery, radars, camps,
 * logistics hubs and installations were six more sources here, and a TAOR gate
 * decided which kinds counted on which ground. All seven are gone: every source
 * left is an object somebody deliberately placed, which is a shorter list and
 * an honest one - the hint points at things that exist rather than at profiles.
 *
 * NEAREST TO THE DEPOSIT, not random. Intel taken off bodies here is about
 * the enemy here - a batch banked at a drop points at the closest thing the
 * network has, which is also the one the section can actually act on. A
 * target already hinted is skipped so the tally walks outward instead of
 * re-marking the same site; once everything has been named the walk starts
 * again.
 *
 * The circle tightens per batch on the same ladder grammar every other
 * product uses.
 *
 * Arguments:
 * 0: Where the batch was deposited <ARRAY> (optional - empty picks at random)
 *
 * Return Value:
 * Anything drawn <BOOL>
 *
 * Public: No
 */

params [["_from", [], [[]]]];

private _side = GVAR(hintSide);
private _pool = [];

// --- the conventional network ----------------------------------------------
{
    _x params ["_id", "_at", "_bSide"];
    if (_bSide getFriend _side < 0.6) then {
        _pool pushBack [_id, _at, "anti-ship battery", "conv"];
    };
} forEach (missionNamespace getVariable [QEGVAR(antiship,batteries), []]);

// Live radar objects, the same not-friendly rule as LOCATE RADAR: an uncrewed
// radar answers `side` as civilian and a getFriend test would hide it.
{
    if (!isNull _x && {alive _x} && {side _x isNotEqualTo _side}) then {
        _pool pushBack [format ["radar_%1", mapGridPosition _x], getPosASL _x, "coastal radar", "conv"];
    };
} forEach (missionNamespace getVariable [QEGVAR(antiship,radars), []]);


{
    _x params ["_at", "_aSide"];
    if (_aSide getFriend _side < 0.6) then {
        _pool pushBack [format ["ad_%1", mapGridPosition _at], _at, "air defence", "conv"];
    };
} forEach (missionNamespace getVariable [QEGVAR(airdefence,sites), []]);





{
    if (!isNull _x && {alive _x}
        && {(_x getVariable [QEGVAR(uas,cacheSide), sideUnknown]) getFriend _side < 0.6}) then {
        _pool pushBack [format ["cache_%1", mapGridPosition _x], getPosATL _x, "drone supply cache", "any"];
    };
} forEach (missionNamespace getVariable [QEGVAR(uas,caches), []]);


if (!isNil "ghost_leaders_houses") then {
    {
        if (!isNull _x) then {
            _pool pushBack [format ["house_%1", _forEachIndex], getPosATL _x, "safe house", "asym"];
        };
    } forEach ghost_leaders_houses;
};

// THE TAOR GATE IS GONE WITH ALiVE. A candidate used to count only where the
// war being fought on its own ground matched what it was - leaders on
// asymmetric ground, air defence on invasion ground - and FUNC(taorType) was
// the one answer to whose ground that was. Nothing knows now, and every source
// left in the pool is an object somebody deliberately placed, so being on the
// map is the whole qualification.

if (_pool isEqualTo []) exitWith {
    INFO("intel hint: nothing hostile on commander ground to point at");
    false
};

// --- the walk ----------------------------------------------------------------
private _hinted = missionNamespace getVariable [QGVAR(hintedIds), []];
private _fresh = _pool select {!((_x select 0) in _hinted)};
// Everything named once already: start the walk again rather than going quiet.
if (_fresh isEqualTo []) then { _fresh = _pool; _hinted = [] };

private _pick = if (_from isEqualTo []) then {
    selectRandom _fresh
} else {
    private _best = _fresh select 0;
    {
        if ((_from distance2D (_x select 1)) < (_from distance2D (_best select 1))) then {
            _best = _x;
        };
    } forEach _fresh;
    _best
};
_pick params ["_id", "_at", "_type"];

private _tier = missionNamespace getVariable [QGVAR(hintTier), 0];
private _radii = ([QGVAR(cfg_circle_radii)] call FUNC(hackSetting)) splitString ", ";
_radii = _radii apply { parseNumber _x };
_radii = _radii select {_x > 0};
if (_radii isEqualTo []) then { _radii = [3000, 2000, 1000] };
private _radius = _radii select (_tier min (count _radii - 1));

// Fraction first, THEN the cap - the setting is a percentage and the cap is a
// fraction, so capping first turned 75% into 0.95% and drew the "fuzzed"
// circle almost exactly on the target.
private _offset = (([QGVAR(cfg_circle_offset)] call FUNC(hackSetting)) / 100);
_offset = 0 max _offset min INTEL_OFFSET_CAP;
private _throw = _radius * _offset;
private _bearing = random 360;
private _centre = _at vectorAdd [sin _bearing * _throw, cos _bearing * _throw, 0];

_hinted pushBack _id;
missionNamespace setVariable [QGVAR(hintedIds), _hinted];
missionNamespace setVariable [QGVAR(hintTier), _tier + 1];

[QGVAR(product), ["circle",
    format [QGVAR(hint_%1), _id],
    _centre, _radius, "", "", toUpper _type, GVAR(hintSide)
]] call CBA_fnc_globalEvent;

INFO_3("intel hint: %1 '%2', %3 m circle",_type,_id,round _radius);
true
