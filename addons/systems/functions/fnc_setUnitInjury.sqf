#include "script_component.hpp"
/*
    File: fn_setUnitInjury.sqf
    Author: YonV
    Description: Applies scripted ACE injuries to a unit. Must run where the unit is
        local - remoteExec with the unit as target (see fn_zenModule_setDamage).

    Arguments:
    0: Unit <OBJECT>
    1: Make unconscious <BOOL> (Default: false)
    2: Injury preset <STRING> (Default: "nothing")
*/

params [
    ["_unit", objNull, [objNull]],
    ["_setUnconscious", false, [true]],
    ["_injury", "nothing", [""]]
];

if (isNull _unit || {!local _unit}) exitWith {};

if (_setUnconscious) then {
    [_unit, true] call ace_medical_fnc_setUnconscious;
};

switch (toLower _injury) do {
    case "twobulletinchest": {
        [_unit, 0.20, "body", "bullet"] call ace_medical_fnc_addDamageToUnit;
        [_unit, 0.20, "body", "bullet"] call ace_medical_fnc_addDamageToUnit;
    };
    case "shrapnellegs": {
        [_unit, 0.15, "leftleg", "grenade"] call ace_medical_fnc_addDamageToUnit;
        [_unit, 0.15, "rightleg", "grenade"] call ace_medical_fnc_addDamageToUnit;
    };
    case "headtrauma": {
        [_unit, 0.25, "head", "backblast"] call ace_medical_fnc_addDamageToUnit;
    };
    default {};
};
