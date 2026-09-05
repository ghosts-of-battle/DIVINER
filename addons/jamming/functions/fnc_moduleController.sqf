#include "script_component.hpp"
/*
 * Author: Ghost
 * Reads the module and arms jamming. PLACING THE MODULE IS THE ENABLE - with no
 * module this system does nothing at all.
 *
 * THIS MODULE IS THE GLOBAL TUNING, NOT A PLACEMENT. It sets what is true of
 * every jamming field on the map - burn-through, the rolled radius bounds, the
 * GPS domain. WHERE a jammer stands is a Ghost - Jammer Site module, placed on
 * the spot by the mission maker or by Zeus.
 *
 * Arguments:
 * 0: The module logic <OBJECT>
 * 1: Synchronised units <ARRAY>
 * 2: Activated <BOOL>
 *
 * Return Value: None
 *
 * Public: No
 */

params [["_logic", objNull, [objNull]], ["_units", [], [[]]], ["_activated", true, [true]]];

if (!_activated || {isNull _logic}) exitWith {};
if (!isServer) exitWith {};

// One module runs this system. A second would re-arm it and place everything
// twice over, so it says so in the log rather than quietly doing it.
if (GVAR(moduleUp)) exitWith {
    WARNING("a second Ghost - Jamming module was placed - ignored, one module runs this system");
};
GVAR(moduleUp) = true;

GVAR(largeRadius) = _logic getVariable ["largeRadius", 3000];
GVAR(smallRadius) = _logic getVariable ["smallRadius", 1000];

// EDEN CHECKBOXES ARRIVE AS 0 AND 1, NOT false AND true. Read straight into a
// GVAR and handed to `&&`, that is "Error &&: Type Number, expected Bool" -
// which is exactly what the 14:48 RPT showed 51 times from FUNC(jammerLoop)
// line 29 and once a tick from FUNC(spawnObjectiveJammers) line 105, with the
// GPS spawner dying on the spot every pass. Coerced here, once, so nothing
// downstream has to know an attribute from a variable.
private _bool = {
    params ["_v"];
    if (_v isEqualType 0) then { _v > 0 } else { _v isEqualTo true }
};

// The GPS domain. Default ON, unlike the model knobs in preInit: placing this
// module is already the deliberate act, and a jamming module that denies the
// net and the data link but silently leaves GPS alone would be the surprising
// answer, not the safe one.
GVAR(gpsEnable) = [_logic getVariable ["gpsEnable", true]] call _bool;
GVAR(gpsUplinkRadius) = _logic getVariable ["gpsUplinkRadius", 400];

// Burn-through. These overwrite the preInit defaults, which are the values
// FUNC(jamFactor) falls back to on a machine the module has not reached.
//
// BROADCAST, because this file exits on !isServer and FUNC(jammerLoop) reads
// jamBurnthrough on every CLIENT to decide whether to ask ACRE for the set's
// power. Server-local, a dedicated server's players would never burn through
// anything however big their radio - the same trap ghost_reaction documents on
// its watts threshold. burnRef needs no broadcast: it is stamped into each
// zone's model at spawn and travels with the registry.
GVAR(jamBurnRef) = _logic getVariable ["burnRef", 500];
missionNamespace setVariable [
    QGVAR(jamBurnthrough), [_logic getVariable ["burnThrough", true]] call _bool, true];

// NOTHING TO WAIT FOR ANY MORE. This used to hold until the ALiVE adapter said
// its commanders were up, because every WHERE the system used came from them.
// Sites are placed by hand now - one Ghost - Jammer Site module each - so the
// only thing left to start is the prune that retires a dead one.
[] call FUNC(start);
