#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelSet

Description:
    Every edit the page makes goes through here to FUNC(adminSet) on the
    server. Nothing is written locally: the server answers with the record it
    now holds (FUNC(adminRecv)), and the page redraws from that.

Parameters:
    0: Field <STRING> - see FUNC(adminSet)
    1: Value <ANY>

Returns:
    Whether a request was sent <BOOL>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_field", "", [""]], "_value"];

if (GVAR(editUid) isEqualTo "") exitWith {false};
if (GVAR(summary) getOrDefault ["readOnly", false]) exitWith {
    ["TAC//PAC", "Store is read-only: it was written by a newer PAC.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify);
    false
};

[player, GVAR(editUid), _field, _value] remoteExec [QFUNC(adminSet), 2];
true
