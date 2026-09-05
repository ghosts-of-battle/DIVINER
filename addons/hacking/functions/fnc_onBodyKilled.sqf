#include "script_component.hpp"
/*
 * Author: Ghost
 * A man died. Decide, once, whether his body is worth searching.
 *
 * WHAT A BODY YIELDS DEPENDS ON WHOSE WAR HE WAS FIGHTING, and that comes
 * from his commander's controltype rather than from a list of factions here:
 *
 *   asymmetric commander's side  - his PHONE. The phone is the insurgency's
 *                                  paperwork, so every insurgent has one.
 *   occupation / invasion side   - his RADIO, when he is actually carrying
 *                                  one. A conventional soldier's set is the
 *                                  same prize by another name: nets, call
 *                                  signs, frequencies.
 *   anyone else                  - the documents roll.
 *
 * Decided at death rather than at search time, so two players searching the
 * same corpse cannot get two different answers.
 *
 * Arguments (Killed EH): 0: the body
 *
 * Return Value: None
 *
 * Public: No
 */

params ["_unit"];

if (!isServer) exitWith {};
if (isPlayer _unit) exitWith {};
if ((side group _unit) isEqualTo civilian) exitWith {};

// Cached at adapter-ready: side text -> controltype. Commanders do not change
// mid-mission, and this runs on every death.
private _type = GVAR(sideControl) getOrDefault [str (side group _unit), ""];

private _has = switch (_type) do {
    case "asymmetric": { [_unit] call FUNC(hasPhone) };
    case "occupation";
    case "invasion":   { [_unit] call FUNC(hasRadio) };
    default            { random 100 < GVAR(docChance) };
};

if (_has) then {
    _unit setVariable [QGVAR(bodyIntel), true, true];
};
