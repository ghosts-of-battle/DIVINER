#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_moduleIntelPackage

Description:
    Puts an intel package on a hackable device, so breaking into that device
    hands over what the mission maker wrote rather than what a simulation
    happened to contain.

    SYNCHRONISE IT, OR IT BUILDS ITS OWN TERMINAL. Attached to something, that
    something carries the package. Attached to nothing, a data terminal is
    created where the module stands - because the common case in Zeus is "put an
    intel objective HERE" and making somebody place a prop first is a step that
    teaches nothing.

    THE PACKAGE IS A NAME, NOT CONTENT. What is in it lives in the mission's own
    config under Ghost_IntelPackages - see FUNC(packageEntries) for the shape.
    This module says which package is on which device, and nothing else: the
    writing is mission content and belongs in the mission, where it can be
    edited without a rebuild and read by somebody who is not looking at Eden.

    IT VALIDATES AT PLACEMENT. A package name that is not in the mission config
    is a typo the mission maker will otherwise discover when a player hacks the
    terminal and is told there is nothing on it. It says so now, in the RPT and
    on the Zeus's screen, while they are still standing next to it.

    ONE PACKAGE PER DEVICE. Placing a second module on the same object replaces
    the first - the device carries one package, and two would mean the share
    arithmetic had to decide which to draw from.

Parameters:
    0: The module logic <OBJECT>
    1: Synchronised units <ARRAY>
    2: Activated <BOOL>

Returns:
    None

Public: No
---------------------------------------------------------------------------- */
params [["_logic", objNull, [objNull]], ["_units", [], [[]]], ["_activated", true, [true]]];

if (!_activated || {isNull _logic}) exitWith {};
if (!isServer) exitWith {};

private _package = _logic getVariable ["package", ""];
_package = [_package] call CBA_fnc_trim;

if (_package isEqualTo "") exitWith {
    WARNING("Intel Package module placed with no package name - nothing attached");
    [objNull, "Intel Package: no package name given"] call BIS_fnc_showCuratorFeedbackMessage;
};

// SAID NOW RATHER THAN AT THE HACK. An empty package is indistinguishable from
// a hacked-out one to the player who finds it.
private _entries = [_package] call FUNC(packageEntries);
if (_entries isEqualTo []) exitWith {
    WARNING_1("Intel Package '%1' is empty or not in the mission config - nothing attached",_package);
    [objNull, format ["Intel Package: '%1' is not in the mission config", _package]]
        call BIS_fnc_showCuratorFeedbackMessage;
};

private _target = _units param [0, objNull, [objNull]];

if (isNull _target) then {
    private _class = _logic getVariable ["terminal", "Land_DataTerminal_01_F"];
    if !(isClass (configFile >> "CfgVehicles" >> _class)) then { _class = "Land_DataTerminal_01_F" };

    _target = createVehicle [_class, [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _target setPosATL (getPosATL _logic);
    _target setDir (getDir _logic);
    _target setVectorUp surfaceNormal (getPosATL _target);

    // Zeus placed it, so Zeus keeps it: without this the terminal it just made
    // is not in its own editable list and cannot be moved or deleted again.
    // Guarded rather than required - hacking does not depend on systems, and a
    // build without it gets a terminal Zeus cannot pick up rather than none.
    if (!isNil QEFUNC(systems,addObjectToCurator)) then {
        [_target] call EFUNC(systems,addObjectToCurator);
    };
};

if (isNull _target) exitWith {
    WARNING_1("Intel Package '%1': no target and no terminal could be created",_package);
};

_target setVariable [QGVAR(package), _package, true];

// A DEVICE WITH A PACKAGE IS HACKABLE, whatever it is. FUNC(scanDevices) offers
// what it recognises as a terminal; this makes anything the module was pointed
// at count, so a mission maker can hang intel on a laptop, a crate or a body
// without asking us to widen a class list.
_target setVariable [QGVAR(hackable), true, true];

INFO_3("intel package '%1' (%2 entries) on %3",_package,count _entries,typeOf _target);

[objNull, format ["Intel Package '%1' attached - %2 files", _package, count _entries]]
    call BIS_fnc_showCuratorFeedbackMessage;

nil
