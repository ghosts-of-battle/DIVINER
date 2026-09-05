#include "script_component.hpp"
/*
 * Author: SGT.Brostrom.A
 * This function return a pylon icon
 *
 * Arguments:
 * 0: VehicleKind <STRING|BOOLEAN>
 * 1: LoadoutName <STRING> (Default; "default")
 *
 * Return Value:
 * DisplayName <STRING>
 *
 * Example:
 * ["rhsusf_m1a1tank_base", "default"] call ghostD_vehicle_fnc_getPylonIcon;
 *
 * Public: No
 */

params [
    ["_classname", "", [""]],
    ["_loadout", "default", [""]]
];


private _icon = EGVAR(init,PYLONS) get _classname get _loadout getOrDefault ["icon", ""];
private _return = [_icon] call EFUNC(systems,getIcon);

_return
