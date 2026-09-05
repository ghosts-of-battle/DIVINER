#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelReport

Description:
    ATTENDANCE TO CLIPBOARD. Asks the server for the open window's report -
    or the latest window's, or all time, in that order - which arrives through
    FUNC(textRecv).

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

[player, "report", ""] remoteExec [QFUNC(adminText), 2];
