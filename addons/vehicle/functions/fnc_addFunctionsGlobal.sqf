#include "script_component.hpp"
/*
 * Author: SGT.Brostrom.A
 * This function apply globla functions to vehicles.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * nothing
 *
 * Example:
 * [_vehicle] call ghostD_vehicle_fnc_addFunctionsGlobal
 *
 * Public: No
 */

params [["_vehicle", objNull, [objNull]]];

if (!isNil{_vehicle getVariable QEGVAR(VehicleFunc,FunctionsGlobal)}) exitWith {SHOW_WARNING_2("VehicleFunctionsGlobal","Vehicle functions already applied for %1 [%2].",_vehicle,typeOf _vehicle);};

TRACE_INFO_2("VehicleFunctionsGlobal","Applying vehicle functions to %1 (%2)",_vehicle,typeOf _vehicle);

private _vehicleType = _vehicle getVariable [QEGVAR(Vehicle,type), typeOf _vehicle];

_vehicle setVariable [QEGVAR(VehicleFunc,FunctionsGlobal), true];

if (!(_vehicle call EFUNC(systems,isValidFaction))) exitWith {};

// Airframes


// Ground vehicles
if (_vehicle isKindOf "MRAP_01_base_F") then {
    switch (_vehicleType) do {
        case "MED": {_vehicle setVariable ["ace_medical_isMedicalVehicle", true, true];};
        default {};
    };
};

if (_vehicle isKindOf "Truck_01_base_F") then {
    switch (_vehicleType) do {
        case "MED": {_vehicle setVariable ["ace_medical_isMedicalVehicle", true, true];};
        default {};
    };
};

