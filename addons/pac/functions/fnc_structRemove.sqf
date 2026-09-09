#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_structRemove

Description:
    REMOVE: asks before taking the selected item out of the structure.
    Records that hold its id read as orphaned until reassigned - that is
    the whole reason it asks.

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

private _list = _display displayCtrl PAC_IDC_ST_LIST;
private _sel = lbCurSel _list;
if (_sel < 0) exitWith {};
private _id = _list lbData _sel;
private _section = [GVAR(structSection)] call FUNC(structBase);

[_id, _section] spawn {
    params ["_id", "_section"];
    private _yes = [format ["Remove '%1' from %2? Every record that holds it will read as orphaned until reassigned.", _id, _section], "TAC//PAC - REMOVE", "Remove", "Cancel"] call BIS_fnc_guiMessage;
    if (_yes) then {
        GVAR(structId) = "";
        [player, _section, "remove", _id, createHashMap] remoteExec [QFUNC(adminStructure), 2];
    };
};
