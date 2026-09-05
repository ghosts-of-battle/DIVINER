#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_serverPick

Description:
    Server end of the choice menu. Builds the snapshot for the chosen product and
    broadcasts the render. Everything that decides WHAT the intel is happens
    here, on one machine, so two clients can never disagree about it.

Parameters:
    _product : STRING - "package" | "coastal" | "jam" | "leader".
    _pos     : ARRAY  - where the hack happened.
    _side    : SIDE   - who earned it.
    _caller  : OBJECT - the hacker.
    _device  : OBJECT - what was hacked. The package lives on it.

Author:
    Ghost
---------------------------------------------------------------------------- */
if (!isServer) exitWith {};

params ["_product", "_pos", "_side", "_caller", ["_device", objNull, [objNull]]];

private _ok = switch (_product) do {
    // THE MISSION'S OWN INTEL, off the terminal that was hacked. A share of the
    // package a Ghost - Intel Package module put on it - see
    // FUNC(productPackage). This is what replaced LOCATE AA, ARTILLERY, CAMP,
    // LOGISTICS, RADAR and INSTALLATION: those six asked ALiVE what it had
    // simulated and drew a circle round it, so what a hack told you was decided
    // by the simulation rather than by anybody. A mission maker can write a
    // document now.
    case "package": { [_device, _side, _caller] call FUNC(productPackage) };

    // The coastal network, split into the launchers and the eyes that feed
    // them - killing one does not kill the other, so they are two hunts. Ghost's
    // own objects, never ALiVE's, which is why this one survived.
    case "coastal": { [_pos, _side] call FUNC(productLocateCoastal) };

    // The jammers holding the quiet up - hack one and its zone dies quietly,
    // blow it and everyone knows you were there.
    case "jam": {
        !isNil "ghostD_jamming_fnc_productLocateJammer"
            && {[_pos, _side] call ghostD_jamming_fnc_productLocateJammer}
    };

    // The asymmetric chain: a circle on a safe house, never on the man.
    case "leader": {
        !isNil "ghost_leaders_fnc_productLeader"
            && {[_pos, _side] call ghost_leaders_fnc_productLeader}
    };

    default { false };
};

// THE PACKAGE HAS ALREADY SPOKEN. It names the folder and how many files came
// off it, which is the whole point of a package over a circle, and a second
// generic line under it would just be noise.
if (_product isEqualTo "package") exitWith {};

// The message never differs either. A player who learns that a poisoned product
// phrases its confirmation differently has been handed the tell for free.
private _msg = ["Nothing to report.", "Intel plotted - check your map."] select _ok;
[QGVAR(pickResult), [_msg, _side]] call CBA_fnc_globalEvent;

INFO_3("Hacking: product '%1' by %2 -> %3",_product,name _caller,_ok);
