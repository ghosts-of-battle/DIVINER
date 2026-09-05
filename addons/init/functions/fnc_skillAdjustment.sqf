#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A
 * This function changes AI skill values
 *
 * Example:
 * call ghostD_init_fnc_skillAdjustment
 *
 * Public: No
 */

INFO("init","Applying AI Event Handler to units...");

if (!isServer) exitWith {};

// COMPILED BY THE MISSION AND HANDED OVER. config\loadConfigs.sqf turns
// config\config_skill.hpp into a function and leaves it here. The file is
// STATEMENTS rather than data - conditionals on difficulty, light level and
// role - so it cannot be a config class; the mission compiles it with _unit
// bound to the name it is written against, and this just calls it.
//
// A mission that hands over nothing leaves AI skill alone, which is the right
// answer for a mission that never asked for adjustment.
GVAR(skillBlock) = missionNamespace getVariable ["ghostFR_missionConfig_skillBlock", {}];

if (GVAR(skillBlock) isEqualTo {}) exitWith {
    INFO("init","This mission handed over no skill block - AI skill left alone.");
};


["CAManBase", "init", {
    params ["_unit"];

    if !(isPlayer _unit) then {
        _unit call GVAR(skillBlock);
    };
}, true, [], true] call CBA_fnc_addClassEventHandler;
