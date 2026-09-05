#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A -- Tinkered with by YonV
 * This function changes appearance for approved vehicles defined in the faction setting.
 * (RHS vehicle handling removed - add per-vehicle blocks here as the GOB motor pool grows.)
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * nothing
 *
 * Example:
 * [_vehicle] call ghostD_vehicle_fnc_addCosmetics;
 *
 * Public: No
 */

params [["_vehicle", objNull, [objNull]]];

if (!isNil{_vehicle getVariable QEGVAR(VehicleFunc,Cosmetics)}) exitWith {SHOW_WARNING_2("VehicleCosmetics","Vehicle cosmetics already applied for %1 [%2].",_vehicle,typeOf _vehicle);};
if (!(_vehicle call EFUNC(systems,isValidFaction))) exitWith {};

TRACE_INFO_2("VehicleCosmetics","Applying vehicle cosmetics to %1 [%2].",_vehicle,typeOf _vehicle);

if (_vehicle isKindOf "NDS_M224_mortar_base") then {
};

_vehicle setPlateNumber "GOB 2040";

// Add eventHandlers to handle death and deletion.
_vehicle addEventHandler ["Killed", {
    params["_vehicle"];
    private _labels = _vehicle getVariable [QEGVAR(Vehicle,Labels), []];
    if (count _labels != 0) then {
        {deleteVehicle _x} forEach _labels;
    };
}];
_vehicle addEventHandler ["Deleted", {
    params["_vehicle"];
    private _labels = _vehicle getVariable [QEGVAR(Vehicle,Labels), []];
    if (count _labels != 0) then {
        {deleteVehicle _x} forEach _labels;
    };
}];

_vehicle setVariable [QEGVAR(VehicleFunc,Cosmetics), true, true];
