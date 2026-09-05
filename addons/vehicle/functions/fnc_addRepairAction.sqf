#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A
 * This function add a repair action to a vehicle inside of a staging zone.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * nothing
 *
 * Example:
 * [_vehicle] call ghostD_vehicle_fnc_addRepairAction
 *
 * Public: No
 */

params [["_vehicle", objNull, [objNull]]];

if (isNull _vehicle) exitWith {};

private _icon = "\A3\ui_f\data\igui\cfg\actions\repair_ca.paa" call EFUNC(systems,getIcon);

private _condition = { call EFUNC(systems,checkStagingZone) };
private _stagingCat = [QEGVAR(Actions_Vehicle,Repair), "Repair and Refuel", _icon, {
     params ["_vehicle", "_caller", "_params"];
     ["", _vehicle] call ace_repair_fnc_doFullRepair;
     _vehicle setFuel 1;
     ["Vehicle", "Vehicle has been refueled and repaired.", NOTE_GOOD] call GHOSTFUNC(notify,notify);
}, _condition] call ace_interact_menu_fnc_createAction;
[_vehicle, 1, ["ACE_SelfActions", QEGVAR(Actions_Vehicle,Main_Cat)], _stagingCat] call ace_interact_menu_fnc_addActionToObject;

