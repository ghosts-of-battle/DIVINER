#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A
 * This module function spawn a Ghosts of Battle Fieald Hostpital.
 *
 * Arguments:
 * 0: modulePos <POSITION>
 * 1: objectPos <OBJECT>
 *
 * Example:
 * [getPos logic, this] call ghostD_zenmodules_fnc_createStaging
 *
 * Public: No
 */

params ["_modulePos", "_objectPos"];


[_objectPos, 12] call ghostD_mission_fnc_addStagingZone;
