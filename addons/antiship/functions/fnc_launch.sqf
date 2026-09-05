#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_antiship_fnc_launch

Description:
    Puts one Burevestnik in the air and, if the battery is playing fair, hangs a
    decoy on it so somebody has a chance of stopping it.

    The decoy is what makes the missile a thing rather than an event. Arma will
    not let AI engage a projectile, so without one this is unstoppable scenery
    that happens to kill a ship on a timer. With one, the missile is something a
    CIWS or an AA gun can be positioned against, and getting caught is a
    consequence of where the defence was rather than a dice roll.

    It launches from a synchronised launcher when there is one - so the battery
    is a place that can be found and destroyed.

Parameters:
    _tgt : OBJECT  - the hull.
    _cfg : HASHMAP - the battery's settings.

Returns:
    BOOL - true if one went up.

Author:
    Ghost
---------------------------------------------------------------------------- */
if (!isServer) exitWith { false };

params ["_tgt", "_cfg"];

if (isNull _tgt) exitWith { false };

// Whichever launcher is still standing. All of them dead means the battery is
// dead - it does not quietly fall back to firing from nowhere.
private _live = (_cfg get "launchers") select { !isNull _x && {alive _x} };
private _hadLaunchers = (_cfg get "launchers") isNotEqualTo [];

if (_hadLaunchers && {_live isEqualTo []}) exitWith {
    if (_cfg get "debug") then {
        diag_log text "[ghostD_antiship] every launcher destroyed - battery silent";
    };
    false
};

private _from = if (_live isEqualTo []) then {
    (_cfg get "pos") vectorAdd [0, 0, 4]
} else {
    (getPosATL (selectRandom _live)) vectorAdd [0, 0, 4]
};

private _missile = createVehicle [
    selectRandom (_cfg getOrDefault ["missiles", [QGVAR(missile)]]),
    _from, [], 0, "CAN_COLLIDE"
];
if (isNull _missile) exitWith {
    diag_log text "[ghostD_antiship] missile failed to create";
    false
};

_missile setPosATL _from;
_missile setVectorDirAndUp [[0, 0, 1], [0, 1, 0]];
_missile setVelocity [0, 0, (_cfg get "speed") * 0.4];

// --- the decoy -------------------------------------------------------------
private _decoy = objNull;
if (_cfg get "interceptable") then {
    // The module's own decoy classes when the field is set - the addon's
    // stock decoys are Darter reskins, which read as WEST airframes over
    // every battery whatever side their config says. The mission maker
    // owns the hostility question then: the tooltip says to pick a class
    // hostile to the ships it will attack.
    private _custom = _cfg getOrDefault ["decoys", []];
    private _class = if (_custom isNotEqualTo []) then {
        selectRandom _custom
    } else {
        // Hostile to whoever owns the ship, or its escorts will not shoot at it.
        private _tside = side _tgt;
        switch (_tside) do {
            case west: { QGVAR(decoy_east) };
            case east: { QGVAR(decoy_west) };
            default {
                [QGVAR(decoy_west), QGVAR(decoy_east)] select ([_tside, east] call BIS_fnc_sideIsEnemy)
            };
        }
    };

    _decoy = createVehicle [_class, [0, 0, 0], [], 0, "NONE"];
    if (!isNull _decoy) then {
        createVehicleCrew _decoy;
        (group _decoy) deleteGroupWhenEmpty true;
        _decoy setMass 0;
        _decoy disableCollisionWith _missile;
        _missile disableCollisionWith _decoy;
        // Above the missile, not on it - a burst that goes off on the missile's
        // own position sets the warhead off early, which arrives anyway.
        _decoy attachTo [_missile, [0, 0, 2]];
    };
};

if (_cfg get "debug") then {
    diag_log text format ["[ghostD_antiship] AWAY at %1 -> %2, %3 m/s%4",
        mapGridPosition _from, typeOf _tgt, _cfg get "speed",
        ["", " (interceptable)"] select (!isNull _decoy)];
};

[_missile, _tgt, _cfg, _decoy] call FUNC(fly);

true
