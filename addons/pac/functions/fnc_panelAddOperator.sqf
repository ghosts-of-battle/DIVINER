#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelAddOperator

Description:
    ADD on the admin page's roster column: reads the Steam id and name beside
    the button and asks the server to put them on the roster
    (FUNC(adminAddOperator)).

    IT ASKS FIRST, like IMPORT CSV, because it writes to the store and because
    the id cannot be corrected afterwards - a record is keyed on it forever.
    The confirmation repeats the id back, which is the only chance anybody has
    to spot a digit typed wrong.

    THE SERVER DECIDES. Everything here is convenience: the checks that matter
    (admin, digits, already on the roster) are made again on the server, which
    is the only place that can be trusted with them.

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

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _uid = trim ctrlText (_display displayCtrl PAC_IDC_L_ADD_UID);
private _name = trim ctrlText (_display displayCtrl PAC_IDC_L_ADD_NAME);

if (_uid isEqualTo "") exitWith {
    ["TAC//PAC", "Type the Steam id of the person to add.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify);
};

[_uid, _name, _display] spawn {
    params ["_uid", "_name", "_display"];

    private _who = [_name, "this Steam id"] select (_name isEqualTo "");
    private _yes = [
        format ["Add %1 to the roster?\n\nSteam id: %2\n\nThe record is keyed on that id and it cannot be changed later - check it against their Steam profile. They arrive with no rank, role or skills.", _who, _uid],
        "TAC//PAC - ADD OPERATOR",
        "Add",
        "Cancel"
    ] call BIS_fnc_guiMessage;

    if (!_yes) exitWith {};

    [player, _uid, _name] remoteExec [QFUNC(adminAddOperator), 2];

    // Cleared so the next add starts empty rather than re-adding the last id.
    // The list itself is refreshed by the store's publish coming back.
    (_display displayCtrl PAC_IDC_L_ADD_UID) ctrlSetText "";
    (_display displayCtrl PAC_IDC_L_ADD_NAME) ctrlSetText "";
};
