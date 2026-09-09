#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_manageSave

Description:
    SAVE in the management window: reads the fields and sends the item to
    the server - an ORBAT item to FUNC(adminOrbat), an operator's fields
    (only the ones that changed) to FUNC(adminSet). The server validates,
    persists, logs and republishes; the list refreshes off that.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(manageDisplay), displayNull];
if (isNull _display) exitWith {};

if (GVAR(summary) getOrDefault ["readOnly", false]) exitWith {
    ["TAC//PAC", "Store is read-only: it was written by a newer PAC.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify);
};

private _section = GVAR(mgSection);
private _id = trim ctrlText (_display displayCtrl PAC_IDC_MG_ID);

// the six edits, by field name
private _values = createHashMap;
{
    _x params ["_editIdc", "_i"];
    ((GVAR(mgFields) # _i) params ["", "_field"]);
    if (_field isNotEqualTo "") then {_values set [_field, trim ctrlText (_display displayCtrl _editIdc)]};
} forEach [[PAC_IDC_MG_F1, 0], [PAC_IDC_MG_F2, 1], [PAC_IDC_MG_F3, 2], [PAC_IDC_MG_F4, 3], [PAC_IDC_MG_F5, 4], [PAC_IDC_MG_F6, 5]];

switch (_section) do {
    case "squads": {
        private _name = _values getOrDefault ["name", ""];
        if (_name isEqualTo "") exitWith {["TAC//PAC", "A squad needs a name.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify)};
        // the key is the squad as it is now (the ID row), "" for a new one
        [player, "squad", "set", _id, _values] remoteExec [QFUNC(adminOrbat), 2];
        GVAR(mgKey) = _name;
    };
    case "platoons": {
        if (_id isEqualTo "") exitWith {["TAC//PAC", "A platoon tab needs an id.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify)};
        _values set ["id", _id];
        GVAR(mgKey) = _id;
        [player, "platoon", "set", _id, _values] remoteExec [QFUNC(adminOrbat), 2];
    };
    case "radionets": {
        if (_id isEqualTo "") exitWith {["TAC//PAC", "A radio net needs an id.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify)};
        _values set ["id", _id];
        GVAR(mgKey) = _id;
        [player, "radioNet", "set", _id, _values] remoteExec [QFUNC(adminOrbat), 2];
    };
    case "faction": {
        [player, "faction", "set", "faction", _values] remoteExec [QFUNC(adminOrbat), 2];
    };
    case "squadradio": {
        if (_id isEqualTo "") exitWith {["TAC//PAC", "Pick a squad first.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify)};
        [player, "squadRadio", "set", _id, _values] remoteExec [QFUNC(adminOrbat), 2];
    };
    case "platoonradio": {
        if (_id isEqualTo "") exitWith {["TAC//PAC", "Pick a platoon first.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify)};
        [player, "platoonRadio", "set", _id, _values] remoteExec [QFUNC(adminOrbat), 2];
    };
    case "operators": {
        if (GVAR(editUid) isEqualTo "" || {count GVAR(editRecord) isEqualTo 0}) exitWith {};
        private _sent = 0;
        {
            if (_y isNotEqualTo (GVAR(editRecord) getOrDefault [_x, ""])) then {
                [player, GVAR(editUid), _x, _y] remoteExec [QFUNC(adminSet), 2];
                _sent = _sent + 1;
            };
        } forEach _values;
        if (_sent isEqualTo 0) then {["TAC//PAC", "Nothing changed.", [0.4, 0.702, 0.4, 1]] call EFUNC(notify,notify)};
    };
};
