#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A, J.Turn
 * This module function spawn a supply crate.
 *
 * Arguments:
 * 0: modulePos <POSITION>
 * 1: objectPos <OBJECT>
 *
 * Example:
 * [getPos logic, this] call ghostD_zenmodules_fnc_createSupplyCrate
 *
 * Public: No
 */

params ["_modulePos", "_objectPos"];
// The crate type that will be passed to the supply crate spawner.
private _crateTypeList = [
    'crate_resupply_general',
    'crate_reaper',
    'crate_nomad',
    'crate_talon',
    'crate_ghost',
    'crate_wraith',
    'crate_medical',
    'crate_medicalInfantry',
    'crate_titan',
    'crate_nlaw',
    'crate_spike',
    'crate_maaws',
    'crate_tow',
    'crate_mo',
    'crate_eng',
    'crate_m2',
    'crate_javelin'
];

// Display text for the crate list selection. This is what the zeus sees.
private _displayTextList =
[
    ['GOB Resupply', "Contains weapons, ammo, and supplies for the whole detachment"],
    ['REAPER Resupply', "Contains weapons, ammo, and supplies for one element (red marking)"],
    ['NOMAD Resupply', "Contains weapons, ammo, and supplies for one element (blue marking)"],
    ['TALON Resupply', "Contains weapons, ammo, and supplies for one element (green marking)"],
    ['GHOST Resupply', "Contains weapons, ammo, and supplies for one element (purple smoke / white marking)"],
    ['WRAITH Resupply', "Contains weapons, ammo, and supplies for one element (yellow marking)"],
    ['Casualty Collection Point', "Contains enough supplies to sustain a CCP as well supplementing one infantry platoon."],
    ['Infantry Medical', "Contains enough medical supplies for one infantry Squad."],
    ['Titan MANPAD', "Contains 1 Titan AA launcher and 4 missiles."],
    ['NLAW Box', "Contains 2 NLAW launchers."],
    ['Spike Box', "Contains 1 Spike launcher and 3 missiles."],
    ['MAAWS Box', "Contains 1 MAAWS launcher, 2 HEAT and 2 HE rockets."],
    ['Titan AT Box', "Contains 1 Titan AT launcher and 4 missiles."],
    ['Mortar Box', "Medium bada boom box"],
    ['Engineering Box', "Demo, and other boom stuff"],
    ['M2 Box', "M2 Ammo, About 2 minutes worth"],
    ['Javelin Box', "Contains 1 launcher and 8 missiles."]
    ];
[
    "Ghosts of Battle Supply Crates", 
    [
        ["LIST", ["Crate Type", "Select the type of unit you are supplying with this crate"],
            [
                _crateTypeList,
                _displayTextList,
                0,
                6
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
