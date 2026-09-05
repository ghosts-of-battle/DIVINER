/*
    Author: TheTimidShade

    Description:
        Fills skill selectors with relevant options for vanilla/ACE

    Parameters:
        NONE
        
    Returns:
        NOTHING
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

disableSerialization;


// get controls
private _admp_display = uiNamespace getVariable ['admp_displayVar', displayNull];
if (isNull _admp_display) exitWith {}; // check display exists

private _medic_combo = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_SKILLS_MEDICAL_COMBO;
private _engineer_combo = _admp_display displayCtrl IDC_ADMINPANEL_PLAYER_SKILLS_ENGINEER_COMBO;

private _medicOptions = [
    ["None", "none", 0],
    ["Medic", "medic", 1]
];
if (admp_aceEnabled) then {_medicOptions pushBack ["Doctor", "doctor", 2];};

private _engineerOptions = [
    ["None", "none", 0],
    ["Engineer", "engineer", 1]
];
if (admp_aceEnabled) then {_engineerOptions pushBack ["Adv Engineer", "advengineer", 2];};

{
    _x params ["_displayName", "_name", "_value"];

    private _entryIndex = _medic_combo lbAdd _displayName;
    _medic_combo lbSetData [_entryIndex, _name];
    _medic_combo lbSetValue [_entryIndex, _value];
} forEach _medicOptions;

{
    _x params ["_displayName", "_name", "_value"];

    private _entryIndex = _engineer_combo lbAdd _displayName;
    _engineer_combo lbSetData [_entryIndex, _name];
    _engineer_combo lbSetValue [_entryIndex, _value];
} forEach _engineerOptions;

[] call admp_fnc_loadPlayerSkills;
