#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_scannerTimer

Description:
    The scanner's stopwatch, cycled by a single keybind: press to start, press
    to stop, press again to clear. One key rather than three because you are
    meant to be able to work it without looking at it, and because there is
    nothing to bind three keys to on a handset.

    Elapsed time is accumulated rather than measured from a single start, so
    stopping and starting again continues the count instead of restarting it.
    Only clearing resets it.

    Runs on mission time, so it stops with the mission rather than running on
    through a pause.

Parameters:
    None - the state lives in GVAR(timerState) / GVAR(timerFrom) /
    GVAR(timerHeld).

Returns:
    NUMBER - the state after the press.

Author:
    Ghost
---------------------------------------------------------------------------- */

switch (GVAR(timerState)) do {
    case SCN_T_IDLE: {
        GVAR(timerFrom) = time;
        GVAR(timerState) = SCN_T_RUNNING;
    };
    case SCN_T_RUNNING: {
        GVAR(timerHeld) = GVAR(timerHeld) + (time - GVAR(timerFrom));
        GVAR(timerState) = SCN_T_STOPPED;
    };
    default {
        GVAR(timerHeld) = 0;
        GVAR(timerFrom) = 0;
        GVAR(timerState) = SCN_T_IDLE;
    };
};

GVAR(timerState)
