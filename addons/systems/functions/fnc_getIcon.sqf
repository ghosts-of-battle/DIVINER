#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A
 * This function return a icon from config or path provided. It also allow a fallback icon
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Fallback Icon <OBJECT>
 *
 * Return Value:
 * Path of icon <STRING>
 *
 * Example:
 * ["\A3\Ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa"] call ghostD_systems_fnc_getIcon
 * ["iconManLeader"] call ghostD_systems_fnc_getIcon
 *
 */

params[["_icon", "", [""]]];

{
    if (_x != "") exitWith {_x};
} forEach [
    getText (configFile >> 'CfgVehicleIcons' >> _icon),
    getText (configFile >> 'CfgGroupIcons' >> _icon >> "icon"),
    getText (configFile >> "CfgUnitInsignia" >> _icon >> "texture"),
    ["",_icon] select (fileExists _icon)
];

""
