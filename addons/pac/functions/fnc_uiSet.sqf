#include "script_component.hpp"
/*
    File: fnc_uiSet.sqf
    Author: YonV
    Description: Set one field of the operator whose page is open - the
        player page's every save. The server (FUNC(adminSet)) answers with
        the record, and the page is told to expect it so it redraws.

    Parameters:
        0: Field <STRING> - one FUNC(adminSet) takes
        1: Value <ANY>

    Returns:
        Nothing
*/

params [["_field", "", [""]], "_value"];

private _uid = GVAR(uiArgs) getOrDefault ["uid", ""];
if (_uid isEqualTo "" || _field isEqualTo "") exitWith {};
GVAR(uiWaiting) pushBackUnique ("record:" + _uid);
[player, _uid, _field, _value] remoteExec [QFUNC(adminSet), 2];
