#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_applyTemp

Description:
    Re-applies the player's skills - PAC's permanent set, then the session's
    temporary effects the admin console put on the unit. Runs where the unit
    is local; the console remoteExecs it after setting ghostD_pac_tempEffects.

Parameters:
    0: The unit <OBJECT>

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]]];
if (isNull _unit || {!local _unit}) exitWith {};

private _row = (missionNamespace getVariable [QGVAR(roster), []]) select {(_x # 0) isEqualTo getPlayerUID _unit};
private _skillIds = if (_row isEqualTo []) then {[]} else {(_row # 0) # 6};
[_unit, _skillIds] call FUNC(applySkills);
