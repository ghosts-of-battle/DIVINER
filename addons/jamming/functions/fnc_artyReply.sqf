#include "script_component.hpp"
/*
 * Author: YonV
 * The site answers back. A hostile who stays inside the field long enough gets
 * artillery on where he was standing.
 *
 * WHY A JAMMER SHOOTS AT ALL. An emitter is a transmitter, and a transmitter is
 * a thing the people who own it are watching. A mast that could be walked up to,
 * studied and demolished at leisure is scenery with a radius; one that answers
 * is a position, and a position has to be assaulted rather than visited.
 *
 * DETECTION IS PRESENCE, NOT LINE OF SIGHT. Anybody hostile inside the field
 * counts, standing in the open or not. This is deliberate and it is not a
 * simplification: the fiction is that the site knows its own field is being
 * walked through - it is direction-finding kit surrounded by its own denial -
 * not that a sentry has eyes on. It also makes the rule legible, which a
 * visibility check never is: players learn "do not loiter inside the ring".
 *
 * THE CLOCK RESETS WHEN THE FIELD IS EMPTY, so crossing a field quickly is free
 * and working inside one is not. That is the whole trade the delay buys.
 *
 * IT FIRES AT THE LAST KNOWN POSITION, scattered. Where the detection was, not
 * where the target is now - so walking away from the ring during the flight
 * time is the counter, and standing still is not. A mission that lands exactly
 * on a moving player is not artillery, it is a smite.
 *
 * IT DIES WITH THE EMITTER. The handler checks the terminal every tick; killing
 * or hacking the site stops the reply along with the jamming, which is what
 * makes assaulting it worth doing.
 *
 * Arguments:
 * 0: The site's terminal <OBJECT>
 * 1: Site config <HASHMAP> - side, radius, delay, rounds, scatter, cooldown
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_terminal", objNull, [objNull]], ["_cfg", createHashMap, [createHashMap]]];

if (!isServer) exitWith {};
if (isNull _terminal) exitWith {};

[{
    params ["_args", "_handle"];
    _args params ["_terminal", "_cfg"];

    // The site is gone - destroyed, hacked, or deleted by a mission cleaning up.
    if (isNull _terminal || {!alive _terminal}) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        TRACE_1("arty reply off, emitter down",_cfg get "pos");
    };

    private _side = _cfg get "side";
    private _pos = getPosATL _terminal;
    private _radius = _cfg get "radius";

    // EVERY MAN IN THE FIELD, hostile to the owner. getFriend rather than a
    // side comparison, because a mission can set west and independent friendly
    // and an ally walking past is not a target.
    private _seen = (_pos nearEntities [["CAManBase", "LandVehicle", "Air", "Ship"], _radius])
        select {alive _x && {(side (group _x)) getFriend _side < 0.6}};

    if (_seen isEqualTo []) exitWith {
        // NOTHING INSIDE, SO NOTHING IS REMEMBERED. The dwell clock restarts
        // from empty rather than carrying, which is what makes a fast crossing
        // survivable and loitering not.
        _cfg set ["since", -1];
    };

    private _since = _cfg getOrDefault ["since", -1];
    if (_since < 0) then {
        _cfg set ["since", CBA_missionTime];
        _since = CBA_missionTime;
    };

    if (CBA_missionTime - _since < (_cfg get "delay")) exitWith {};

    // The cooldown is checked only once somebody has actually earned a mission,
    // so a field being crossed repeatedly does not silently burn the timer down
    // between crossings.
    private _last = _cfg getOrDefault ["lastFire", -1e9];
    if (CBA_missionTime - _last < (_cfg get "cooldown")) exitWith {};

    _cfg set ["lastFire", CBA_missionTime];
    _cfg set ["since", -1];

    // THE ONE NEAREST THE EMITTER, not a random one. A site defends itself
    // first; the man closest to it is the one it is answering.
    private _target = _seen select 0;
    {
        if (_x distance _terminal < _target distance _terminal) then {_target = _x};
    } forEach _seen;

    private _at = getPosATL _target;

    INFO_3("%1 jammer site replying: %2 rounds on %3",_cfg get "domain",_cfg get "rounds",mapGridPosition _at);

    // Spread over a third of the delay, so it arrives as a shoot rather than
    // all at once, and so the first round is a warning the rest are coming.
    [_at, _cfg get "rounds", _cfg get "scatter", "Sh_155mm_AMOS", (_cfg get "delay") / 3]
        call EFUNC(common,fireBarrage);

}, JAM_ARTY_TICK, [_terminal, _cfg]] call CBA_fnc_addPerFrameHandler;

nil
