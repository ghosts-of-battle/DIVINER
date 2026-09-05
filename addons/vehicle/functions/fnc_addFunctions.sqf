#include "script_component.hpp"
/*
 * Author: SGT.Brostrom.A -- Tinkered with by YonV
 * This function apply functions to local vehicles.
 * (RHS, CUP and USAF airframe blocks removed - add blocks for the GOB motor pool here.)
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * nothing
 *
 * Example:
 * [_vehicle] call ghostD_vehicle_fnc_addFunctions;
 *
 * Public: No
 */

params [["_vehicle", objNull, [objNull]]];

if (!isNil{_vehicle getVariable QEGVAR(VehicleFunc,Functions)}) exitWith {SHOW_WARNING_2("VehicleFunctions","Vehicle functions already applied for %1 [%2].",_vehicle,typeOf _vehicle);};

TRACE_INFO_2("VehicleFunctions","Applying vehicle functions to %1 (%2)",_vehicle,typeOf _vehicle);


_vehicle setVariable [QEGVAR(VehicleFunc,Functions), true];


// Jump and get out systems universal for all airframes and non nato factions.
if (_vehicle isKindOf "Heli_Transport_01_base_F") then {
    [_vehicle] call EFUNC(mission,addGetOutHelo);
    [_vehicle] call EFUNC(mission,addEscapeWreck);
};

if (_vehicle isKindOf "B_UAV_06_medical_F") then {
    _vehicle setVariable ["ace_medical_isMedicalVehicle", true, true];
};

if (_vehicle isKindOf "Heli_Transport_02_base_F") then {
    [_vehicle] call EFUNC(mission,addLineJump);
    [_vehicle] call EFUNC(mission,addEscapeWreck);
};

if (_vehicle isKindOf "B_Plane_Transport_01_infantry_F") then {
    [_vehicle] call EFUNC(mission,addLineJump);
    [_vehicle] call EFUNC(mission,addHaloJump);
    [_vehicle] call EFUNC(mission,addEscapeWreck);
};

if (_vehicle isKindOf "VTOL_01_infantry_base_F") then {
    [_vehicle] call EFUNC(mission,addLineJump);
    [_vehicle] call EFUNC(mission,addHaloJump);
    [_vehicle] call EFUNC(mission,addEscapeWreck);
};

