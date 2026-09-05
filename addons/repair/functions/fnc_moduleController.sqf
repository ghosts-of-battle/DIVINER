#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_repair_fnc_moduleController

Description:
    Takes charge of everything synchronised to the module.

    A snapshot of each object is taken NOW, at mission start, while it is still
    intact: class, position, orientation, and whether it was crewed. That is what
    a respawn is rebuilt from. Reading any of it later is too late - a destroyed
    object may have been thrown down a hill by the blast, and a deleted one
    cannot be asked anything at all.

Parameters (module standard): logic, units, activated

Author:
    Ghost
---------------------------------------------------------------------------- */
if (hasInterface && !isServer) exitWith {};

params [
    ["_logic", objNull, [objNull]],
    ["_units", [], [[]]],
    ["_activated", true, [true]]
];

if (!_activated) exitWith {};
if (isNull _logic) exitWith {};

private _objects = (synchronizedObjects _logic) select { !(_x isKindOf "Logic") };
if (_objects isEqualTo []) exitWith {
    diag_log text "[ghost_repair] module placed with nothing synchronised to it";
};

private _cfg = createHashMapFromArray [
    ["interval", (_logic getVariable ["interval", REP_INTERVAL_DEF]) max 1],
    ["amount", (0 max (_logic getVariable ["repair_amount", 1])) min 1],
    ["rearm", _logic getVariable ["rearm", true]],
    ["refuel", _logic getVariable ["refuel", true]],
    ["recrew", _logic getVariable ["replace_crew", false]],
    ["respawn", _logic getVariable ["respawn", false]],
    ["respawnDelay", (_logic getVariable ["respawn_delay", REP_RESPAWN_DEF]) max 0],
    ["debug", _logic getVariable ["debug", false]]
];

// One record per charge: [object, class, posATL, dir, vectorUp, wasCrewed,
// diedAt, nextService]. The object slot is rewritten when a respawn replaces it.
private _records = _objects apply {
    [
        _x,
        typeOf _x,
        getPosATL _x,
        getDir _x,
        vectorUp _x,
        // An autonomous vehicle counts as crewed whether or not its UAV AI is
        // seated yet: module init runs before the mission has finished crewing
        // things, and a snapshot that catches an AA piece in that gap records
        // it as never-crewed - so its respawn came back a permanently empty
        // hull. The config knows what the moment cannot.
        (crew _x) isNotEqualTo [] || {getNumber (configOf _x >> "isUav") > 0},
        -1,
        CBA_missionTime + (_cfg get "interval")
    ]
};

_logic setVariable [QGVAR(cfg), _cfg];
_logic setVariable [QGVAR(records), _records];

[FUNC(tick), REP_TICK, _logic] call CBA_fnc_addPerFrameHandler;

diag_log text format [
    "[ghost_repair] online: %1 object(s), every %2s, repair %3, rearm %4, respawn %5",
    count _records, _cfg get "interval", _cfg get "amount",
    _cfg get "rearm", _cfg get "respawn"
];
