#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_intelOptions

Description:
    What this hack could be made to produce, given where it is happening and
    what the mission currently has. Also keeps the session's choice valid when
    the list changes under it.

    It lived inside FUNC(tabletRefresh), which meant the answer only existed
    while the suite's own dialog was on screen - anything else that wanted to
    offer the same choices had to work them out again and could disagree. It is
    a question about the mission, not about a display.

    WHAT THIS DEVICE CAN BE MADE TO PRODUCE. A package if somebody put one on
    it, plus whatever hunts the mission currently has anything to hunt.

    IT WAS SCOPED BY TAOR, AND IS NOT ANY MORE. FUNC(taorType) asked ALiVE which
    commander held the spot and what kind of war it was fighting - invasion and
    occupation offered the integrated defence network, asymmetric offered the
    leader chain. That question died with ALiVE, and it was the wrong question:
    what a terminal can tell you is a fact about the terminal, which is now
    exactly what a mission maker writes on it.

    AN EMPTY LIST IS STILL POSSIBLE and still says so. A device nobody put a
    package on, on a map with no anti-ship, no jammers and no leaders, has
    nothing to offer - and a button that can only ever say "nothing" teaches
    players to stop reading the list.

Parameters:
    _session : HASHMAP - the tablet session. Optional, default the live one.

Returns:
    ARRAY - [id, label] pairs, capped at TAB_INTEL.

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_session", GVAR(session), [createHashMap]]];

private _avail = [];

if ((_session get "kind") isEqualTo "drone") exitWith {
    // A drone hack does one thing; there is nothing to choose.
    _avail = [["none", "DOWN THE DRONE"]];
    GVAR(intelAvailable) = _avail;
    _session set ["intel", "none"];
    _avail
};

// THE DEVICE DECIDES, not the ground it stands on. This used to switch on
// FUNC(taorType) - which commander held this spot and what kind of war it was
// fighting - and offer a different menu on each. That question was ALiVE's and
// has no answer now, and it was answering the wrong thing anyway: what a
// terminal can tell you is a fact about the terminal.
private _device = _session getOrDefault ["device", objNull];

// The mission's own intel, if somebody put a package on this device with a
// Ghost - Intel Package module. First in the list because it is the reason to
// hack a terminal rather than a thing you might also get.
if (!isNull _device && {(_device getVariable [QGVAR(package), ""]) isNotEqualTo ""}) then {
    _avail pushBack ["package", "DOWNLOAD FILES"];
};

// The anti-ship network, split into the launchers and the eyes that feed them -
// killing one does not kill the other, so they are two hunts. Both read ghost's
// own objects, which is why they outlived the six that read ALiVE's.
if ((missionNamespace getVariable [QEGVAR(antiship,batteries), []]) isNotEqualTo []) then {
    _avail pushBack ["coastal", "LOCATE ANTI-SHIP"];
};
if ((missionNamespace getVariable [QEGVAR(antiship,radars), []]) isNotEqualTo []) then {
    _avail pushBack ["radar", "LOCATE RADAR"];
};

// The jammers holding the quiet up.
if ((missionNamespace getVariable ["ghostD_jamming_zoneCount", 0]) > 0) then {
    _avail pushBack ["jam", "LOCATE JAMMER"];
};

// The asymmetric chain, if the leaders addon is loaded - it is not, in DIVINER,
// and the guard is what makes that a missing product rather than an error.
if ((missionNamespace getVariable ["ghost_leaders_upCount", 0]) > 0) then {
    _avail pushBack ["leader", "TRACE NETWORK"];
};

if (count _avail > TAB_INTEL) then { _avail = _avail select [0, TAB_INTEL] };
GVAR(intelAvailable) = _avail;

// Keep the selection valid when the list changes under it.
//
// AN EMPTY LIST LEAVES THE SELECTION ALONE. Blanking it made the session carry
// no product, which a gate in FUNC(tabletAction) then refused to start on - and
// a hack that will not begin reads as a broken hack, not as a considered
// refusal. The scoping decides what is OFFERED; it does not decide whether the
// suite works.
private _intel = _session get "intel";
if (_avail isNotEqualTo [] && {(_avail findIf { (_x select 0) isEqualTo _intel }) < 0}) then {
    _session set ["intel", (_avail param [0, ["", ""]]) select 0];
};

_avail
