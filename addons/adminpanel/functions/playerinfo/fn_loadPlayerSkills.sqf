/*
    Author: TheTimidShade

    Description:
        Updates player skill combo boxes when a player is selected

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

private _medicSkill = _player getVariable ["ace_medical_medicClass", parseNumber (_player getUnitTrait "Medic")];
private _engineerSkill = _player getVariable ["ACE_IsEngineer", parseNumber (_player getUnitTrait "Engineer")];
private _eodSkill = _player getVariable ["ACE_isEOD", _player getUnitTrait "ExplosiveSpecialist"];
private _draSkill = _player getVariable ["draWhitelisted", false];
private _isrSkill = _player getVariable ["isISR", false];
private _jfoSkill = _player getVariable ["isJFO", false];
private _uavSkill = _player getVariable ["UAVHacker", _player getUnitTrait "UAVHacker"];
private _leadSkill = (_player getVariable ["isLeader", false]) isEqualTo true;

if (isNull _player) then {
    _medicSkill = 0;
    _engineerSkill = 0;
    _eodSkill = false;
    _draSkill = false;
    _isrSkill = false;
    _jfoSkill = false;
    _uavSkill = false;
    _leadSkill = false;
};

_medic_combo lbSetCurSel _medicSkill;
_engineer_combo lbSetCurSel _engineerSkill;
_eod_checkbox cbSetChecked _eodSkill;
_dra_checkbox cbSetChecked _draSkill;
_isr_checkbox cbSetChecked _isrSkill;
_jfo_checkbox cbSetChecked _jfoSkill;
_uav_checkbox cbSetChecked _uavSkill;
_lead_checkbox cbSetChecked _leadSkill;
