#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_structOpened

Description:
    onLoad of the structure editor: fills the section combo and shows the
    section that was open last (ranks the first time).

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
if !([player] call ghostD_adminpanel_fnc_isAdmin) exitWith {closeDialog 2};

private _display = uiNamespace getVariable [QGVAR(structDisplay), displayNull];
if (isNull _display) exitWith {};

private _combo = _display displayCtrl PAC_IDC_ST_SECTION;
lbClear _combo;
private _sel = 0;
{
    _x params ["_id", "_label"];
    private _i = _combo lbAdd _label;
    _combo lbSetData [_i, _id];
    if (_id isEqualTo GVAR(structSection)) then {_sel = _i};
} forEach [["ranks", "RANKS"], ["skills", "SKILLS"], ["awards", "AWARDS"], ["statuses", "STATUSES"], ["roles", "ROLES"], ["nets", "NETS"], ["promotion", "PROMOTION"], ["admins", "ADMINS"]];
_combo lbSetCurSel _sel;     // fires structSection
