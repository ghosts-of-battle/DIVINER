#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_bootLog

Description:
    One line of the boot sequence, where it can be seen: the .rpt (which a
    dedicated server's console shows live), and on screen when the server
    is a hosted game or the editor. Every step of FUNC(boot) goes through
    here so the whole sequence reads top to bottom in one grep:

        [TAC//PAC BOOT 3/7] store: profile 12 player(s) -> file gfa_pac.ini read

    The lines are also kept in GVAR(bootLog) and published, so the admin
    page can show the last boot without the .rpt.

Parameters:
    0: Step, e.g. "3/7" <STRING>
    1: Text <STRING>

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_step", "", [""]], ["_text", "", [""]]];

private _line = format ["[TAC//PAC BOOT %1] %2", _step, _text];
diag_log _line;

GVAR(bootLog) pushBack _line;

// PUBLISHED PER LINE, small and cheap, so a client's boot screen
// (FUNC(bootScreen)) shows the steps as they happen and not only the whole
// log at READY. GVAR(bootStep) is the fraction done, off the "n/6" step.
if (isServer) then {
    private _parts = _step splitString "/";
    if (count _parts >= 2) then {
        GVAR(bootStep) = (parseNumber (_parts # 0)) / ((parseNumber (_parts # 1)) max 1);
        publicVariable QGVAR(bootStep);
    };
    publicVariable QGVAR(bootLog);
};
