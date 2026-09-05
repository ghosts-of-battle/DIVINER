#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_alarmSilence

Description:
    Shuts the ringing alarm up on THIS machine.

    LOCAL, AND ONLY LOCAL. The roster is the section's - see FUNC(alarmAdd) -
    but the noise is not: a man who has heard it and is now trying to listen to
    a radio should not have to take the alarm off everybody else to do it, and
    an alarm somebody else set is not his to cancel. Nothing is removed from the
    roster and nothing is broadcast; the beep stops here.

    Silence is also not a snooze. The alarm has already fired and is finished -
    this only ends the sixty seconds of beeping it does afterwards.

Parameters:
    None

Returns:
    BOOL - true if there was something to silence.

Example:
    [] call ghostD_hacking_fnc_alarmSilence

Author:
    Ghost
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {false};

private _ringing = GVAR(alarmRingUntil) > time;

// Ends the beep loop on its next tick, and the roster's RINGING flag with it -
// both read this same number.
GVAR(alarmRingUntil) = -1;

if (GVAR(alarmBeepPFH) != -1) then {
    [GVAR(alarmBeepPFH)] call CBA_fnc_removePerFrameHandler;
    GVAR(alarmBeepPFH) = -1;
};

_ringing
