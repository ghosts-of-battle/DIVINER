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

// SETTINGS, NOT A SCRIPT (2026-09-09). This used to require the mission to
// compile config\config_skill.hpp and hand the function over, so a mission
// with no config\ folder left every AI at Arma's own skill and nothing said
// why. FUNC(aiSkill) reads the sliders instead - and still calls the mission's
// own block first when it has one, so a mission that ships the file is
// unchanged.
//
// The switch above this is unchanged: "Arma Default" writes no skill at all.
private _own = missionNamespace getVariable ["ghostFR_missionConfig_skillBlock", {}];
// Hoisted: a comma inside a macro argument reads as an argument separator.
private _said = ["the settings", "this mission's own skill block"] select (_own isNotEqualTo {});
INFO_1("init","AI skill: %1",_said);

["CAManBase", "init", {
    params ["_unit"];

    if !(isPlayer _unit) then {
        _unit call FUNC(aiSkill);
    };
}, true, [], true] call CBA_fnc_addClassEventHandler;
