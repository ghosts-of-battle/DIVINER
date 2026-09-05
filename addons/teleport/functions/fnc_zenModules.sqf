#include "script_component.hpp"
/*
 * Author: Reeveli
 * Registers the Zeus (ZEN) modules: place a point, and open the menu.
 *
 * ZEN IS OPTIONAL. Without it this does nothing and the rest of the system -
 * the action, the menu, Eden-placed points - works exactly the same.
 *
 * Arguments: None
 *
 * Return Value: None
 *
 * Public: No
 */

if (!hasInterface) exitWith {};
if (!isClass (configFile >> "CfgPatches" >> "zen_custom_modules")) exitWith {};

[
    "Ghosts of Battle",
    "Add teleport point",
    {[_this select 1] call FUNC(zenDialog)},
    "a3\ui_f_curator\data\cfgwrapperui\cursors\curatormove_ca.paa"
] call zen_custom_modules_fnc_register;

[
    "Ghosts of Battle",
    "Open teleport menu",
    {[] call FUNC(open)}
] call zen_custom_modules_fnc_register;
