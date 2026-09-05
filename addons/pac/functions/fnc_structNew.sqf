#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_structNew

Description:
    NEW: clears the fields so a new item can be typed. Nothing is written
    until SAVE.

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

GVAR(structId) = "";
(_display displayCtrl PAC_IDC_ST_LIST) lbSetCurSel -1;
{(_display displayCtrl _x) ctrlSetText ""} forEach [PAC_IDC_ST_ID, PAC_IDC_ST_NAME, PAC_IDC_ST_F1, PAC_IDC_ST_F2, PAC_IDC_ST_F3];
ctrlSetFocus (_display displayCtrl PAC_IDC_ST_ID);
