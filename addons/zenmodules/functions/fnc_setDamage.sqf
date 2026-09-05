#include "script_component.hpp"
/*
    File: fn_zenModule_setDamage.sqf
    Author: CPL.Brostrom.A -- Tinkered with by YonV
    Description: ZEN module - applies scripted injuries (and optional unconsciousness)
        to the unit the module is placed on. Useful for medical training scenarios.

    Arguments:
    0: modulePos <POSITION>
    1: objectPos <OBJECT>
*/

params ["_modulePos", "_objectPos"];

if !(_objectPos isKindOf "CAManBase") exitWith {
    ["Place the module on a unit"] call zen_common_fnc_showMessage;
};

[
    "Set Unit Injury",
    [
        ["CHECKBOX", ["Make unit unconscious", ""], true, false],
        ["LIST", ["Injury", "Select type of injury"],
            [
                ["nothing","twoBulletInChest","shrapnelLegs","headTrauma"],
                [["Nothing",""],["2 bullets in the chest",""],["Shrapnel to the legs",""],["Head trauma",""]],
                0,
                4
            ], false]
    ],
    {
        params ["_arg", "_pos"];
        _arg params ["_setUnconscious","_injury"];
        _pos params ["_unit"];

        [_unit, _setUnconscious, _injury] remoteExec [QEFUNC(systems,setUnitInjury), _unit];
    },
    {},
    [_objectPos]
] call zen_dialog_fnc_create;
