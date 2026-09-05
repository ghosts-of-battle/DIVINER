#include "script_component.hpp"
/*
 * Author: Ghost
 * THE PRE-SPAWN GATE: may this side put something at this position? Asked by
 * every module system before a computed-position spawn, after wrong-side
 * sightings kept coming back one addon at a time - the answer belongs in one
 * place, not re-derived in each.
 *
 * The rule: inside the side's own ground, and never on somebody else's. The
 * TAOR comes from the caller when it has its own markers (a module attribute),
 * and nowhere else - there is no second source since ALiVE went.
 *
 * NO TAOR OF ITS OWN MEANS THE WHOLE MAP - ALiVE's own convention, and the
 * hole this gate used to have. It read "no TAOR, no gate" and waved every
 * spawn through, so a side whose commander declares no placements - which on
 * this mission is BLUFOR - could put drones and hardware anywhere, including
 * deep inside the red TAOR. The RPT proved it: not one refusal all mission
 * while west flew nine patrols. Now an undeclared side is still bounded by
 * everyone ELSE's declarations: hostile ground is added to its blacklist, so
 * "anywhere" stops at the enemy's boundary. FUNC(plan) in air defence already
 * did this for itself; it belongs here, where every system gets it.
 *
 * A refusal warns with the caller's tag, so the RPT says which system
 * held its fire and where.
 *
 * Arguments:
 * 0: Side <SIDE>
 * 1: Position <ARRAY>
 * 2: Caller tag for the log <STRING> (optional)
 * 3: TAOR marker names <ARRAY> (optional - none means the whole map)
 * 4: Blacklist marker names <ARRAY> (optional)
 * 5: Do not warn on a refusal <BOOL> (optional, default false)
 *
 * QUIET IS FOR BULK. The warning is written for one refused spawn, where it is
 * the only record that a system held its fire. A caller filtering a whole list
 * through the gate - every objective a commander holds, every QRF origin -
 * would turn that into sixty lines a minute saying the same thing, so it says
 * how many it dropped instead. Single-spawn callers stay loud.
 *
 * Return Value:
 * The spawn may go ahead <BOOL>
 *
 * Example:
 * if (!([east, _pos, "uas patrol"] call ghostD_common_fnc_taorGate)) exitWith {false};
 *
 * Public: Yes
 */

params [
    ["_side", sideUnknown, [sideUnknown]],
    ["_pos", [], [[]]],
    ["_tag", "", [""]],
    ["_taor", [], [[]]],
    ["_black", [], [[]]],
    ["_quiet", false, [false]]
];

if (_pos isEqualTo []) exitWith {true};

// COPIED BEFORE IT IS TOUCHED. params hands back the caller's own array, and
// the foreign ground below is pushed into it - without this, one gated spawn
// would permanently grow its caller's blacklist.
_black = +_black;

// THE ADAPTER USED TO FILL THESE IN. Two blocks stood here: one asked ALiVE for
// a side's own TAOR when the caller passed none, and one walked every other
// commander's TAOR to build the foreign ground a side with no declaration of its
// own is still bounded by. Both are gone with ALiVE, and nothing else in the mod
// knows where a side operates.
//
// SO THE CALLER'S MARKERS ARE THE WHOLE ANSWER NOW. Pass a TAOR and it gates on
// it; pass none and this returns true, which is the same "no TAOR is the whole
// map" convention it always used - it just has no second source to consult
// first. A caller that wants an area is expected to carry one.

if (_taor isEqualTo [] && {_black isEqualTo []}) exitWith {true};

// An empty TAOR is the whole map, so the own-ground half is vacuously true and
// the blacklist - which now carries hostile ground - is what does the work.
private _ok = (_taor isEqualTo [] || {(_taor findIf {_pos inArea _x}) > -1})
    && {(_black findIf {_pos inArea _x}) == -1};

if (!_ok && {!_quiet}) then {
    WARNING_3("taorGate: refused %1 at %2 (%3) - outside the side's ground",_side,mapGridPosition _pos,_tag);
};

_ok
