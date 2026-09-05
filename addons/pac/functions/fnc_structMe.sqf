#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_structMe

Description:
    ADD ME (admins section): puts the player's own Steam id and name into
    the fields, ready to SAVE - the first admin on a fresh database.

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
if (GVAR(structSection) isNotEqualTo "admins") exitWith {};

(_display displayCtrl PAC_IDC_ST_ID) ctrlSetText ([player] call FUNC(uid));
(_display displayCtrl PAC_IDC_ST_NAME) ctrlSetText name player;
