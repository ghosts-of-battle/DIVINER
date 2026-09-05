#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_structSave

Description:
    SAVE: reads the fields, sends the item to the server
    (FUNC(adminStructure) "set"). The server validates, persists and
    republishes; the list refreshes off that.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(structDisplay), displayNull];
if (isNull _display) exitWith {};

// a role id is a class name and a net id is its name on the radio: both keep
// their case; every other id is lower case
private _id = trim ctrlText (_display displayCtrl PAC_IDC_ST_ID);
if !(GVAR(structSection) in ["roles", "nets"]) then {_id = toLower _id};
if (_id isEqualTo "") exitWith {["TAC//PAC", "An id is needed.", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify)};

private _rec = createHashMapFromArray [["name", trim ctrlText (_display displayCtrl PAC_IDC_ST_NAME)]];
{
    _x params ["_editIdc", "_i"];
    ((GVAR(structFields) # _i) params ["", "_field"]);
    if (_field isNotEqualTo "") then {_rec set [_field, trim ctrlText (_display displayCtrl _editIdc)]};
} forEach [[PAC_IDC_ST_F1, 0], [PAC_IDC_ST_F2, 1], [PAC_IDC_ST_F3, 2]];

GVAR(structId) = _id;
[player, GVAR(structSection), "set", _id, _rec] remoteExec [QFUNC(adminStructure), 2];
