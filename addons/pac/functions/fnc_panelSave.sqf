#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelSave

Description:
    The SAVE button on the admin page: asks the server to force-write the
    store and re-publish now (FUNC(adminSave)). Edits already save on their
    own, debounced; this is the "put it down now" confirmation.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

if (GVAR(summary) getOrDefault ["readOnly", false]) exitWith {
    ["TAC//PAC", "Store is read-only: it was written by a newer PAC.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify);
};

[player] remoteExec [QFUNC(adminSave), 2];
