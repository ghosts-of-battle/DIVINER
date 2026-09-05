#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_manageNew

Description:
    NEW in the management window: clears the id and the fields so a new
    ORBAT item can be typed. Nothing is written until SAVE.

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

GVAR(mgKey) = "";
(_display displayCtrl PAC_IDC_MG_LIST) lbSetCurSel -1;
{(_display displayCtrl _x) ctrlSetText ""} forEach [PAC_IDC_MG_ID, PAC_IDC_MG_F1, PAC_IDC_MG_F2, PAC_IDC_MG_F3, PAC_IDC_MG_F4, PAC_IDC_MG_F5, PAC_IDC_MG_F6];
if (GVAR(mgSection) isEqualTo "squads") then {(_display displayCtrl PAC_IDC_MG_F3) ctrlSetText "true"};
ctrlSetFocus (_display displayCtrl ([PAC_IDC_MG_F1, PAC_IDC_MG_ID] select (GVAR(mgSection) in ["platoons", "radionets"])));
