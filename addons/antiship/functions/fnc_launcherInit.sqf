#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_antiship_fnc_launcherInit

Description:
    Brings one launcher on line. Placed in Eden, spawned by Zeus or dropped by a
    script - all the same, the same way the radar does it.

    THERE IS NO MODULE, AND THAT IS THE CHANGE. In ghost this addon was driven by
    ghost_moduleAntiShip: switch a side on and it SITED a battery for you, on
    coastal ground inside that side's ALiVE TAOR markers. DIVINER has no TAORs
    and no commanders to own them, so the siting had nowhere to read from - and
    the honest replacement is not a smaller module, it is putting the launcher
    where you want it. A mission maker knows which headland the battery is on.

    ONE LAUNCHER IS ONE BATTERY. The module grouped several under one clock; a
    hand-placed launcher owns its own, so three launchers on a headland are three
    tubes on three cycles rather than one battery firing three times as fast.
    That is the more predictable answer for somebody placing them by eye, and it
    means deleting one launcher removes exactly one tube.

    THE RADARS ARE SHARED AND READ LIVE. FUNC(pickTarget) is handed the whole
    registry each cycle rather than a list baked in here, so a radar placed after
    the launcher still sees for it - which is the ordinary case in Zeus, where
    the launcher goes down first because it is the thing being hidden.

    IT REGISTERS ITSELF AS A BATTERY. [id, position, side] into
    QGVAR(batteries), broadcast, because the hacking suite's LOCATE ANTI-SHIP
    product and its Intel Hunt pool both read that registry on the client. Keyed
    by grid rather than by netId: a battery is a PLACE to those products, and the
    id has to survive the object being replaced.

Parameters:
    0: OBJECT - the launcher.

Author:
    YonV
---------------------------------------------------------------------------- */
params [["_launcher", objNull, [objNull]]];

if (!isServer || {isNull _launcher}) exitWith {};
if (_launcher getVariable [QGVAR(registered), false]) exitWith {};
_launcher setVariable [QGVAR(registered), true];

// WHO OWNS IT. A crewed static answers `side` through its gunner; an empty one
// answers civilian, which would make it hostile to nobody and invisible to every
// product. The config side is the fallback, and it is the class's own - our
// launcher inherits an OPFOR SAM, so an uncrewed one placed and forgotten still
// reads as east rather than as scenery.
private _side = side _launcher;
if (_side isEqualTo civilian) then {
    _side = [east, west, independent, civilian] param [
        getNumber (configOf _launcher >> "side") min 3 max 0, east
    ];
};

private _id = format ["coastal_%1", mapGridPosition _launcher];

private _reg = missionNamespace getVariable [QGVAR(batteries), []];
_reg pushBack [_id, getPosASL _launcher, _side];
missionNamespace setVariable [QGVAR(batteries), _reg, true];

// The tuning is settings now rather than module attributes - one battery cannot
// have its own interval when there is no module to give it one, and a mission
// that wants two different behaviours has a bigger question than this addon.
private _cfg = createHashMapFromArray [
    ["pos", getPosASL _launcher],
    ["side", _side],
    ["launchers", [_launcher]],
    ["interval", GVAR(interval)],
    ["range", GVAR(searchRange)],
    ["terminal", GVAR(terminalRange)],
    ["cruiseAlt", GVAR(cruiseAlt)],
    ["speed", GVAR(missileSpeed)],
    ["interceptable", GVAR(interceptable)],
    ["debug", GVAR(debug)],
    ["targets", (GVAR(targetClasses) splitString ",") apply {trim _x} select {_x isNotEqualTo ""}],
    ["missiles", [QGVAR(missile)]],
    ["decoys", []]
];

_launcher setVariable [QGVAR(cfg), _cfg];

// THE FIRST SHOT IS NOT AT MISSION START. A battery that fires the instant a
// hull is in range on the first tick is a battery that opens the mission, which
// is rarely what placing one is for.
_launcher setVariable [QGVAR(nextFire), CBA_missionTime + GVAR(interval)];

[{
    params ["_args", "_handle"];
    _args params ["_launcher"];

    if (isNull _launcher || {!alive _launcher}) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    // Read live, so a radar sited later sees for a launcher placed earlier.
    private _cfg = _launcher getVariable [QGVAR(cfg), createHashMap];
    _cfg set ["radars", (missionNamespace getVariable [QGVAR(radars), []]) select {!isNull _x}];

    [[_launcher], _handle] call FUNC(tick);
}, AS_TICK, [_launcher]] call CBA_fnc_addPerFrameHandler;

INFO_2("anti-ship launcher on line: %1 at %2",_side,mapGridPosition _launcher);

nil
