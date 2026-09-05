#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_antiship_fnc_pickTarget

Description:
    Finds a hull worth a missile.

    Classes are matched by INHERITANCE rather than by exact name. The static
    carrier and destroyer are assembled from dozens of part classes that all
    descend from one base, and "Ship" covers every boat in the game - a list of
    exact names would miss most of a carrier and every mod's vessels.

    Nearest wins. A coastal battery shoots at what is closest to its coast.

Parameters:
    _cfg : HASHMAP - the battery's settings.

Returns:
    OBJECT - the hull, objNull if the sea is empty.

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_cfg"];

private _from = _cfg get "pos";
private _classes = _cfg get "targets";
if (_classes isEqualTo []) exitWith { objNull };
private _range = _cfg get "range";

// WHERE THE PICTURE COMES FROM. With radars synced to the battery it comes from
// them and from nothing else - the launchers are inland behind terrain and
// cannot see the sea, which is the point of putting them there. Kill the
// radars, or wait out their tracks, and the battery is blind.
//
// With none synced the battery looks for itself, as it always did, so a mission
// built before the radar existed still works.
private _radars = _cfg getOrDefault ["radars", []];
private _candidates = [];

if (_radars isNotEqualTo []) then {
    private _now = CBA_missionTime;
    {
        private _radar = _x;
        if (!alive _radar) then { continue };
        // A hacked set contributes nothing while the intrusion holds. Guarded:
        // the IADS addon is optional, and without it no radar is ever hacked.
        {
            _x params ["_obj", "", "_t"];
            if (!isNull _obj && { _now - _t < AS_RADAR_TRACK }) then {
                _candidates pushBackUnique _obj;
            };
        } forEach (_radar getVariable [QGVAR(contacts), []]);
    } forEach _radars;
} else {
    // The type filter matters: an empty one makes this "every object on the map
    // inside 12 km", walked on every tick of every battery, and a coastline is
    // the most object-dense ground in Arma. The isKindOf pass below still runs -
    // this only stops the engine handing us the rocks.
    _candidates = nearestObjects [_from, _classes, _range];
};

private _best = objNull;
private _bestD = -1;

{
    private _obj = _x;
    if (!alive _obj) then { continue };
    if (_classes findIf { _obj isKindOf _x } < 0) then { continue };

    private _d = _from distance2D _obj;
    // a contact a radar can see is not automatically one the battery can reach
    if (_d > _range) then { continue };
    if (_bestD < 0 || _d < _bestD) then { _bestD = _d; _best = _obj };
} forEach _candidates;

if (!isNull _best && {_cfg get "debug"}) then {
    diag_log text format ["[ghostD_antiship] target: %1 at %2m, grid %3",
        typeOf _best, round _bestD, mapGridPosition (getPosATL _best)];
};

_best
