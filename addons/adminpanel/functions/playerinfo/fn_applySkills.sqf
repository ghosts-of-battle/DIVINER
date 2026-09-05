/*
    Author: TheTimidShade

    Description:
        Applies player skills/traits based on selected values

    Parameters:
        NONE

    Returns:
        NONE
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

disableSerialization;


private _admp_display = uiNamespace getVariable ['admp_displayVar', displayNull];
if (isNull _admp_display) exitWith {}; // check display exists

private _admp_playerlist_listbox = _admp_display displayCtrl IDC_ADMINPANEL_PLAYERLIST_LISTBOX;
private _medic_combo = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_SKILLS_MEDICAL_COMBO;
private _engineer_combo = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_SKILLS_ENGINEER_COMBO;
private _eod_checkbox = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_SKILLS_EOD_CHECKBOX;
private _dra_checkbox = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_SKILLS_DRA_CHECKBOX;
private _isr_checkbox = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_SKILLS_ISR_CHECKBOX;
private _jfo_checkbox = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_SKILLS_JFO_CHECKBOX;
private _uav_checkbox = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_SKILLS_UAV_CHECKBOX;
private _lead_checkbox = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_SKILLS_LEAD_CHECKBOX;

private _player = [_admp_playerlist_listbox] call admp_fnc_playerFromSelection; // get selected player
if (isNull _player) exitWith {["Admin Panel", "No target found!", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify); playSound "addItemFailed";}; // if there is no selected target exit

private _medicSkill = _medic_combo lbValue (lbCurSel _medic_combo);
private _engineerSkill = _engineer_combo lbValue (lbCurSel _engineer_combo);
private _eodSkill = cbChecked _eod_checkbox;
private _draSkill = cbChecked _dra_checkbox;
private _isrSkill = cbChecked _isr_checkbox;
private _jfoSkill = cbChecked _jfo_checkbox;
private _uavSkill = cbChecked _uav_checkbox;
private _leadSkill = cbChecked _lead_checkbox;


// SESSION ONLY. With TAC//PAC loaded these go on as temporary effects that
// PAC applies over the player's permanent skills until they respawn or
// rejoin; only what is set in the PAC page is permanent. Without PAC the
// variables below are all there is, as before.
private _temp = [format ["medic:%1", _medicSkill], format ["engineer:%1", _engineerSkill], format ["eod:%1", [0, 1] select _eodSkill]];
if (_draSkill) then {_temp pushBack "var:draWhitelisted=true"};
if (_isrSkill) then {_temp pushBack "trait:isISR"};
if (_jfoSkill) then {_temp pushBack "trait:isJFO"};
if (_uavSkill) then {_temp pushBack "trait:UAVHacker"};
if (_leadSkill) then {_temp pushBack "trait:isLeader"};
_player setVariable ["ghostD_pac_tempEffects", _temp, true];
if (!isNil "ghostD_pac_fnc_applySkills") then {
    [_player, "temp"] remoteExecCall ["ghostD_pac_fnc_applyTemp", _player];
};

_player setVariable ["ace_medical_medicClass", _medicSkill, true];
_player setVariable ["ACE_IsEngineer", _engineerSkill, true];
_player setVariable ["ACE_isEOD", _eodSkill, true];
_player setVariable ["draWhitelisted", _draSkill, true];
_player setVariable ["isISR", _isrSkill, true];
_player setVariable ["isJFO", _jfoSkill, true];
_player setVariable ["UAVHacker", _uavSkill, true];
// The platoon-view / HQ-tag / support gate flag - the mission's own name.
_player setVariable ["isLeader", _leadSkill, true];

// setUnitTrait needs the unit local, so run on the unit's machine
[_player, ["Medic", _medicSkill > 0]] remoteExecCall ["setUnitTrait", _player];
[_player, ["Engineer", _engineerSkill > 0]] remoteExecCall ["setUnitTrait", _player];
[_player, ["ExplosiveSpecialist", _eodSkill]] remoteExecCall ["setUnitTrait", _player];
[_player, ["UAVHacker", _uavSkill]] remoteExecCall ["setUnitTrait", _player];


["Admin Panel", format ["Applied skills to %1%2", name _player, [" (session only - permanent skills are set in TAC//PAC)", "!"] select (isNil "ghostD_pac_fnc_applySkills")], [0.4, 0.702, 0.4, 1]] call EFUNC(notify,notify);
playSound "3DEN_notificationDefault";
