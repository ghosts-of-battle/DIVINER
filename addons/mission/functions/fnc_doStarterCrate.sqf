#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A
 * It adds equipment and some selections to a given object.
 *
 * Arguments:
 * 0: Object <OBJECT>
 * 1: Heal action <BOOL>            (Default: true)
 * 2: Staging <BOOL>                (Default: true)
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [this] call ghostD_mission_fnc_doStarterCrate;
 * [this,true,false] call ghostD_mission_fnc_doStarterCrate;
 * [this,false,true] call ghostD_mission_fnc_doStarterCrate;
 *
 */

params [
    ["_object", objNull, [objNull]],
    ["_reHealOption", true, [true]],
    ["_hasStagingZone", true, [true]]
];

INFO_2("StarterCrate","Starting to apply functions to %1 (%2)",_object,typeOf _object);


// Call addHeal options
if (_reHealOption) then {
    [_object] call EFUNC(systems,addHeal);
    [_object] call EFUNC(systems,addHealall);
};

// Stageing zone
if (_hasStagingZone) then {
    [_object, 25] call FUNC(addStagingZone);
};
