#include "script_component.hpp"
/*
    File: fn_zenModule_createMedicalCrate.sqf
    Author: CPL.Brostrom.A -- Tinkered with by YonV
    Description: ZEN module - spawns a medical supply crate (server side via
        doSupplyCrate, same path as the supply crate module).

    Arguments:
    0: modulePos <POSITION>
    1: objectPos <OBJECT>
*/

params ["_modulePos", "_objectPos"];

// The crate type that will be passed to the supply crate spawner.
private _crateTypeList = [
    'crate_medical',
    'crate_medicalInfantry'
];

// Display text for the crate list selection. This is what the zeus sees.
private _displayTextList =
[
    ['CCP', "Full medic resupply - mirrors the medic role loadout plus basic supplies."],
    ['Infantry Squad', "Basic self-aid medical supplies for one infantry squad."]
];

[
    "Ghosts of Battle Medical Crate",
    [
        ["LIST", ["Crate Type", "Select the type of unit you are supplying with this crate"],
            [
                _crateTypeList,
                _displayTextList,
                0,
                2
            ], false]
    ],
    {
        params ["_arg", "_pos"];
        _arg params ["_crateType"];
        _pos params ["_modulePos"];

        [_modulePos, _crateType] remoteExec [QEFUNC(logistics,doSupplyCrate), 2, false];
    },
    {},
    [_modulePos]
] call zen_dialog_fnc_create;
