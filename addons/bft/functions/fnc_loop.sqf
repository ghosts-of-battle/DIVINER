#include "script_component.hpp"
/*
 * Author: Jacco Douma, Ghost
 * One redraw, then reschedules itself. In multiplayer the wait is aligned to
 * server time, so every client's markers step at the same instant - two players
 * looking at the same map see the same picture rather than pictures a second or
 * two apart.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ghostD_bft_fnc_loop
 *
 * Public: No
 */

[] call FUNC(remove);

// Markers are cleared before the check, so switching the system off takes the
// picture with it rather than freezing it.
if (!GVAR(enabled)) exitWith {
    GVAR(loopRunning) = false;
};

// RESCHEDULED BEFORE THE DRAW, NOT AFTER IT. The draw is the part that can
// throw - a marker name that will not take, a group that vanished mid-pass - and
// an error ends the script it is in. With the next tick booked at the bottom,
// one bad frame stopped the tracker for the rest of the mission and looked
// exactly like it stopped "after a teleport". Booked first, a bad pass costs one
// second of markers.
private _delay = round GVAR(updateDelay);
private _sleepTime = _delay;
if (isMultiplayer) then {
    _sleepTime = _delay - (serverTime % _delay);
};

[FUNC(loop), [], _sleepTime] call CBA_fnc_waitAndExecute;

[] call FUNC(draw);
