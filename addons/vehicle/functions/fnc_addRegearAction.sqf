#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A
 * This function add a reGear action to a vehicle inside of a staging zone.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * nothing
 *
 * Example:
 * [_vehicle] call ghostD_vehicle_fnc_addRegearAction
 *
 * Public: No
 */

params [["_vehicle", objNull, [objNull]]];

if (isNull _vehicle) exitWith {};

private _icon = "z\ghostD\addons\media\images\logo_256.paa" call EFUNC(systems,getIcon);

private _condition = { call EFUNC(systems,checkStagingZone) };
private _stagingCat = [QEGVAR(Actions_Vehicle,Repair), "Regear", _icon, {
     params ["_vehicle"];

     private _vehicleLoadout = _vehicle getVariable [QEGVAR(vehicle,pylon), ["", []]];
     _vehicleLoadout params ["_loadoutName", "_pylon"];

     [_vehicle, _loadoutName, _pylon] call EFUNC(vehicle,applyLoadout);
     _vehicle setFuel 1;
     ["Vehicle", "Vehicle has been resupplied.", NOTE_GOOD] call GHOSTFUNC(notify,notify);
}, _condition] call ace_interact_menu_fnc_createAction;
[_vehicle, 1, ["ACE_SelfActions", QEGVAR(Actions_Vehicle,Main_Cat)], _stagingCat] call ace_interact_menu_fnc_addActionToObject;

