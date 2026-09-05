/*
    Author: TheTimidShade

    Description:
        Gets selected player's medical stats
        Returns N/A if ace is disabled

    Parameters:
        0: OBJECT - Unit to retrieve stats from
        
    Returns:
        ARRAY - ["conscious", "bpm", "bldpres", "bldvol", "pain", "o2", "bloodType"]
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

params [
    ["_unit", objNull, [objNull]]
];

// if (!admp_aceEnabled || isNull _unit) then {
//     ["N/A", "N/A", "N/A", "N/A", "N/A"]
// };

// The two colours here are deliberately NOT the theme's. Conscious and
// unconscious is a medical state, not a piece of chrome - green and red mean the
// same thing in every scheme, and an accent-coloured STATUS would say nothing.
private _conscious = ["<t color='#47ed00'>Conscious</t>", "<t color='#ff0000'>Unconscious</t>"] select (_unit getVariable ["ACE_isUnconscious", false]);
private _bpm = str round (_unit getVariable ["ACE_medical_heartrate", 0]);

private _pressure = _unit getVariable ["ACE_medical_bloodpressure", [0,0]];
private _bldpres = format ["%1/%2", _pressure#0, _pressure#1];

private _bldvol = (_unit getVariable ["ACE_medical_bloodvolume", 0]); 
_bldvol = (_bldvol toFixed 2);

private _pain = (_unit getVariable ["ACE_medical_pain", 0]);
private _pain = (_pain toFixed 2);

private _o2 = str round (_unit getVariable ["ACE_medical_spo2", 0]);

// the blood type is not ACE's - see ghostD_common_fnc_bloodType
private _blood = [_unit] call ghostD_common_fnc_bloodType;
if (_blood isEqualTo "") then { _blood = "N/A" };

private _medInfo = [_conscious, _bpm, _bldpres, _bldvol, _pain, _o2, _blood];

_medInfo
