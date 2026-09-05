/*
    Author: TheTimidShade

    Description:
        Updates player medical info displays 

    Parameters:
        0: ARRAY - Array of stats from admp_fnc_getPlayerMedicalInfo
        
    Returns:
        NONE
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

disableSerialization;


params ["_dataArray"];

private _admp_display = uiNamespace getVariable ['admp_displayVar', displayNull];
if (isNull _admp_display) exitWith {}; // check display exists

// get all medical status display controls
private _status_display = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_MEDICAL_STATUS;
private _bpm_display = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_MEDICAL_HEART;
private _bldpres_display = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_MEDICAL_BLDPRES;
private _bldvol_display = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_MEDICAL_BLDVOL;
private _pain_display = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_MEDICAL_PAIN;
private _sp02_display = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_MEDICAL_SP02;
private _blood_display = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_MEDICAL_BLOOD;

// update status on controls
//
// LABEL AND VALUE - see EFUNC(adminpanel,infoRow). STATUS keeps its own markup
// because admp_fnc_getPlayerMedicalInfo colours the word itself.
_status_display ctrlSetStructuredText parseText ("<t font='RobotoCondensedBold' size='0.85'>" + _dataArray#0 + "</t>");
[_bpm_display, "HEART RATE", _dataArray # 1] call FUNC(infoRow);
[_bldpres_display, "BLOOD PRES", _dataArray # 2] call FUNC(infoRow);
[_bldvol_display, "BLOOD VOL", format ["%1 L", _dataArray # 3]] call FUNC(infoRow);
[_pain_display, "PAIN", _dataArray # 4] call FUNC(infoRow);
[_sp02_display, "SPO2", _dataArray # 5] call FUNC(infoRow);
[_blood_display, "BLOOD TYPE", _dataArray param [6, "N/A"]] call FUNC(infoRow);
