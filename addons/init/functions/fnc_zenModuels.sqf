#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A, SPC.Turn.J
 * This function load all GOB modules. Requires Zen Mod to run propperly. The function will terminate if not.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * call ghostD_init_fnc_zenModuels
 *
 * Public: No
 */

if !(EGVAR(patches,usesZen)) exitWith {};

INFO("init","Initializing custom Zen Modules.");

["GOB AI", "Enable Unit Simulation",
    {
        params ["_modulePos", "_objectPos"];
        [_modulePos, _objectPos] call EFUNC(zenmodules,EnableUnitSimulation);    
    },
    "\A3\ui_f\data\map\vehicleicons\iconManVirtual_ca.paa"
] call zen_custom_modules_fnc_register;


["GOB Logistics", "Staging Zone",
    {
        params ["_modulePos", "_objectPos"];
        [_modulePos, _objectPos]  call EFUNC(zenmodules,createStaging);    
    },
    "\A3\ui_f\data\map\vehicleicons\iconCrate_ca.paa"
] call zen_custom_modules_fnc_register;

["GOB Logistics", "Add Staging",
    {
        params ["_modulePos", "_objectPos"];
        [_modulePos, _objectPos]  call EFUNC(zenmodules,addStaging);    
    },
    "\A3\ui_f\data\map\vehicleicons\iconCrate_ca.paa"
] call zen_custom_modules_fnc_register;

["GOB Logistics", "Spawn Re-supply Crate",
    {
        params ["_modulePos", "_objectPos"];
        [_modulePos, _objectPos] call EFUNC(zenmodules,CreateSupplyCrate);
    },
    "\A3\ui_f\data\map\vehicleicons\iconCrate_ca.paa"
] call zen_custom_modules_fnc_register;

if (EGVAR(Settings,enableRadios)) then {
    ["GOB Mission", "Reset Radio",
        {
            params ["_modulePos", "_objectPos"];
            [_modulePos, _objectPos] call EFUNC(zenmodules,ResetPlayerRadio);
        },
        "\a3\modules_f\data\portraitmodule_ca.paa"
    ] call zen_custom_modules_fnc_register;
};

["GOB Mission", "Call Endex",
    {
        params ["_modulePos", "_objectPos"];
        [_modulePos, _objectPos] call EFUNC(zenmodules,CallEndex);
    },
    "\a3\modules_f\data\portraitmodule_ca.paa"
] call zen_custom_modules_fnc_register;

["GOB Mission", "Take attendance",
    {
        [QGVAR(getAttendance)] call CBA_fnc_localEvent;
        ["All attended players have been saved to your RPT log"] call zen_common_fnc_showMessage;
    },
    "\a3\modules_f\data\portraitmodule_ca.paa"
] call zen_custom_modules_fnc_register;

["GOB Mission", "Staging Zones",
    {
        params ["_modulePos", "_objectPos"];
        [_modulePos, _objectPos] call EFUNC(zenmodules,stagingZones);
    },
    "\a3\modules_f\data\portraitmodule_ca.paa"
] call zen_custom_modules_fnc_register;

["GOB Logistics", "Spawn Field Hospital",
    {
        params ["_modulePos", "_objectPos"];
        [_modulePos, _objectPos] call EFUNC(zenmodules,createFieldHospital);
    },
    "\A3\ui_f\data\map\vehicleicons\iconCrate_ca.paa"
] call zen_custom_modules_fnc_register;

["GOB Logistics", "Spawn Medical Crate",
    {
        params ["_modulePos", "_objectPos"];
        [_modulePos, _objectPos] call EFUNC(zenmodules,createMedicalCrate);
    },
    "\A3\ui_f\data\map\vehicleicons\iconCrate_ca.paa"
] call zen_custom_modules_fnc_register;

["GOB Logistics", "Spawn Starter Crate",
    {
        params ["_modulePos", "_objectPos"];
        [_modulePos, _objectPos] call EFUNC(zenmodules,CreateStarterCrate);
    },
    "\A3\ui_f\data\map\vehicleicons\iconCrate_ca.paa"
] call zen_custom_modules_fnc_register;

["GOB AI", "Set Unit Injury",
    {
        params ["_modulePos", "_objectPos"];
        [_modulePos, _objectPos] call EFUNC(zenmodules,setDamage);
    },
    "\A3\ui_f\data\map\vehicleicons\iconManMedic_ca.paa"
] call zen_custom_modules_fnc_register;

INFO("init","Custom Zen Modules initialization complete");
