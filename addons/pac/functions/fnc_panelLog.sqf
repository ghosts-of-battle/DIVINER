#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelLog

Description:
    Fills the RECENT ACTIONS list on the admin page from the log rows the
    server last sent (FUNC(logRecv)), newest first. No-op unless the page
    is open.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _list = _display displayCtrl PAC_IDC_LOG_LIST;
lbClear _list;

{
    _x params [["_id", ""], ["_when", ""], "", ["_byName", ""], ["_type", ""], "", ["_target", ""], ["_detail", ""]];
    _list lbAdd format ["%1  %2  %3%4  %5", _when select [0, 16], _byName, _type, ["", "  " + _target] select (_target isNotEqualTo ""), _detail];
} forEach GVAR(logRows);

if (lbSize _list isEqualTo 0) then {
    _list lbAdd "nothing logged yet - every rank, role, skill, award, note, window and edit lands here, dated";
};
