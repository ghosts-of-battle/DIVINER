#include "script_component.hpp"
/*
 * Author: SGT.Brostrom.A
 * This function changes the inventory of the given vehicle.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * nothing
 *
 * Example:
 * [_vehicle] call ghostD_vehicle_fnc_addInventory;
 *
 * Public: No
 */

params [["_vehicle", objNull, [objNull]]];

if (!EGVAR(Settings,enableVehicleInventory)) exitWith {};
if (!isNil{_vehicle getVariable QEGVAR(VehicleFunc,Inventory)}) exitWith {SHOW_WARNING_2("VehicleInventory","Vehicle inventory already applied for %1 [%2].",_vehicle,typeOf _vehicle);};
if (!(_vehicle call EFUNC(systems,isValidFaction))) exitWith {};

TRACE_INFO_2("VehicleInventory","Applying vehicle inventory to %1 (%2)",_vehicle,typeOf _vehicle);

private _vehicleType = _vehicle getVariable [QEGVAR(Vehicle,type), typeOf _vehicle];


// Remove ACE Cargo
private _cargoArray = _vehicle getVariable ["ace_cargo_loaded",[]];
{
    [_x, _vehicle] call ace_cargo_fnc_removeCargoItem;
} forEach _cargoArray;

// Do not allow renaming of vehicles
_vehicle setVariable ["ace_cargo_noRename", true, true];

_vehicle setVariable [QEGVAR(VehicleFunc,Inventory), true, true];

if (_vehicleType == "EMPTY") exitWith { [_vehicle, []] call EFUNC(logistics,setCargo); };


/* Ground Vehicles -------------------------------------------------------------------------------------------------- */
if (_vehicle isKindOf "MRAP_01_base_F") then {
    
    // Cargo
    switch (true) do {
        case "MED": {
            [_vehicle, 
                GET_CONTAINER("wheeled_medical")
            ] call EFUNC(logistics,setCargo);

            ["ace_medicalSupplyCrate",
                GET_CONTAINER("crate_medical"),
                _vehicle
            ] call EFUNC(logistics,createCargoCrate);
        };
        default {
            [_vehicle, 4, 20, false, false] call EFUNC(logistics,setCargoAttributes);
            
        };
    };
    
    ["ACE_Wheel", _vehicle, true] call ace_cargo_fnc_loadItem;

    // Interior
    switch (_vehicleType) do {
        case "MED": {
            [_vehicle, 
                GET_CONTAINER("wheeled_medical")
            ] call EFUNC(logistics,setCargo);

            ["ace_medicalSupplyCrate",
                GET_CONTAINER("crate_medical"),
                _vehicle
            ] call EFUNC(logistics,createCargoCrate);
        };
        default {
            [_vehicle, 
                GET_CONTAINER("vehicle_mrap")
            ] call EFUNC(logistics,setCargo);
        };
    };
};

if (_vehicle isKindOf "APC_Tracked_01_base_F") then {
        switch (_vehicleType) do {
        case "MED": {
            [_vehicle, 
                GET_CONTAINER("tracked_medical")
            ] call EFUNC(logistics,setCargo);

            ["ace_medicalSupplyCrate",
                GET_CONTAINER("crate_medical"),
                _vehicle
            ] call EFUNC(logistics,createCargoCrate);
        };
        default {
            [_vehicle, 
                GET_CONTAINER("vehicle_Tracked")
            ] call EFUNC(logistics,setCargo);
        };
    };
};

if (_vehicle isKindOf "APC_Tracked_02_base_F") then {
        switch (_vehicleType) do {
        case "MED": {
            [_vehicle, 
                GET_CONTAINER("tracked_medical")
            ] call EFUNC(logistics,setCargo);

            ["ace_medicalSupplyCrate",
                GET_CONTAINER("crate_medical"),
                _vehicle
            ] call EFUNC(logistics,createCargoCrate);
        };
        default {
            [_vehicle, 
                GET_CONTAINER("vehicle_Tracked")
            ] call EFUNC(logistics,setCargo);
        };
    };
};

if (_vehicle isKindOf "APC_Wheeled_01_base_F") then {
    switch (_vehicleType) do {
        case "B_APC_Wheeled_01_medical_F";
        case "MED": {
            [_vehicle, 
                GET_CONTAINER("wheeled_medical")
            ] call EFUNC(logistics,setCargo);

            ["ace_medicalSupplyCrate",
                GET_CONTAINER("crate_medical"),
                _vehicle
            ] call EFUNC(logistics,createCargoCrate);
        };
        default {
            [_vehicle, 
                GET_CONTAINER("vehicle_Wheeled")
            ] call EFUNC(logistics,setCargo);
        };
    };
    ["ACE_Wheel", _vehicle, true] call ace_cargo_fnc_loadItem;
};

if (_vehicle isKindOf "Truck_01_base_F") then {
    switch (_vehicleType) do {
        case "MED": {
            [_vehicle, 
                GET_CONTAINER("wheeled_medical")
            ] call EFUNC(logistics,setCargo);

            ["ace_medicalSupplyCrate",
                GET_CONTAINER("crate_medical"),
                _vehicle
            ] call EFUNC(logistics,createCargoCrate);
        };
        default {
            [_vehicle, 
                GET_CONTAINER("vehicle_Wheeled")
            ] call EFUNC(logistics,setCargo);
        };
    };
    ["ACE_Wheel", _vehicle, true] call ace_cargo_fnc_loadItem;
};

/* water toys ------------------------------------------------------------------------------------------------------- */
if (_vehicle isKindOf "Boat_F") then {
        switch (_vehicleType) do {
        default {
            [_vehicle, 
                GET_CONTAINER("vehicle_boat")
            ] call EFUNC(logistics,setCargo);
        };
    };
};

// Deployable


// Rotary Wing
if (_vehicle isKindOf "Helicopter_Base_H") then {
    switch (_vehicleType) do {
        case "B_Heli_Transport_01_medevac_F";
        case "B_W_Heli_Transport_01_medevac_F"; 
        case "B_T_Heli_Transport_01_medevac_F"; 
        case "B_Heli_Transport_01_medevac_F";
        case "MED": {
            [_vehicle, 
                GET_CONTAINER("helo_medical")
            ] call EFUNC(logistics,setCargo);

            ["ace_medicalSupplyCrate",
                GET_CONTAINER("crate_medical"),
                _vehicle
            ] call EFUNC(logistics,createCargoCrate);
        };
        default {
            [_vehicle, 
                GET_CONTAINER("vehicle_heliTransport")
            ] call EFUNC(logistics,setCargo);
        };
    };
};

if (_vehicle isKindOf "Heli_Transport_01_base_F") then {
    switch (_vehicleType) do {
        case "B_Heli_Transport_01_medevac_F";
        case "B_W_Heli_Transport_01_medevac_F"; 
        case "B_T_Heli_Transport_01_medevac_F"; 
        case "B_Heli_Transport_01_medevac_F";
        case "MED": {
            [_vehicle, 
                GET_CONTAINER("helo_medical")
            ] call EFUNC(logistics,setCargo);

            ["ace_medicalSupplyCrate",
                GET_CONTAINER("crate_medical"),
                _vehicle
            ] call EFUNC(logistics,createCargoCrate);
        };
        default {
            [_vehicle, 
                GET_CONTAINER("vehicle_heliTransport")
            ] call EFUNC(logistics,setCargo);
        };
    };
};

if (_vehicle isKindOf "Heli_Transport_03_base_F") then {
    switch (_vehicleType) do {
        case "YMF_helicopters_B_Heli_Medevac_031_F";
        case "YMF_helicopters_B_Heli_Medevac_03dazt_F";
        case "YMF_helicopters_B_Heli_Medevac_03daz_F"; 
        case "MED": {
            [_vehicle, 
                GET_CONTAINER("helo_medical")
            ] call EFUNC(logistics,setCargo);

            ["ace_medicalSupplyCrate",
                GET_CONTAINER("crate_medical"),
                _vehicle
            ] call EFUNC(logistics,createCargoCrate);
        };
        default {
            [_vehicle, 
                GET_CONTAINER("vehicle_heliTransport")
            ] call EFUNC(logistics,setCargo);
        };
    };
};
        
if (_vehicle isKindOf "Heli_EC_01_base_RF") then {
    switch (_vehicleType) do {
        case "MED": {
            [_vehicle, 
                GET_CONTAINER("helo_medical")
            ] call EFUNC(logistics,setCargo);

            ["ace_medicalSupplyCrate",
                GET_CONTAINER("crate_medical"),
                _vehicle
            ] call EFUNC(logistics,createCargoCrate);
        };
        default {
            [_vehicle, 
                GET_CONTAINER("vehicle_heliTransport")
            ] call EFUNC(logistics,setCargo);
        };
    };
};

if (_vehicle isKindOf "Heli_Transport_02_base_F") then {
    [_vehicle, 
        GET_CONTAINER("vehicle_heliTransport")
    ] call EFUNC(logistics,setCargo);
};

// Fixed Wing
if (_vehicle isKindOf "Plane_Transport_01_base_F") then {
    [_vehicle, 45, -1, false, false] call EFUNC(logistics,setCargoAttributes);

    [_vehicle, 
        GET_CONTAINER("vehicle_planeTransport")
    ] call EFUNC(logistics,setCargo);
};

if (_vehicle isKindOf "VTOL_01_unarmed_base_F") then {
    [_vehicle, 45, -1, false, false] call EFUNC(logistics,setCargoAttributes);

    [_vehicle, 
        GET_CONTAINER("vehicle_planeTransport")
    ] call EFUNC(logistics,setCargo);
};


// QAV MV-35 PHANTOM - a helicopter load in a fixed-wing class tree. Its own
// base is VTOL_03_unarmed_base_QAV : VTOL_Base_F : Plane_Base_F, so neither
// the Helicopter_Base_H block above nor the VTOL_01 one just above ever
// matched, so the aircraft flew on QAV's own stock load - on the MJTF Woodland
// that is two EF MXCs, four coyote mags, two red smokes, four FirstAidKits, a
// Toolkit, a Medikit and twenty-four parachutes, none of them ours. It is a
// rear-ramp troop lift, so it draws the TRANSPORT HELICOPTER container (user,
// 2026-09-01). setCargo clears first, so the parachutes go with the rest -
// the same as the Blackfish above.
//
// vehicle_heliTransport and vehicle_planeTransport are the same ten lines
// today - the choice is the NAME, and the name is what any future edit to
// either list will follow.
//
// The base class covers every variant: base/T/W/D from QAV_MV35 and
// QAV_MV35_WS, and MJTF Woodland, MJTF Desert and Navy from QAV_MV35_EF.
//
// ACE cargo SPACE is left at the default, unlike the Blackfish above at 45 -
// this sets what is IN the aircraft, which is what a transport helicopter
// load means. Say so and it gets a ramp aircraft's space as well.
if (_vehicle isKindOf "VTOL_03_unarmed_base_QAV") then {
    [_vehicle, 
        GET_CONTAINER("vehicle_heliTransport")
    ] call EFUNC(logistics,setCargo);
};


/* drones ----------------------------------------------------------------------------------------------------------- */
if (_vehicle isKindOf "UAV_06_base_F") then {
    switch (_vehicleType) do {
        case "B_UAV_06_medical_F"; 
        case "Aegis_B_D_UAV_06_medical_F"; 
        case "B_T_UAV_06_medical_F"; 
        case "B_W_UAV_06_medical_F";
        case "MED": {
            [_vehicle, 
                GET_CONTAINER("droneair_medical")
            ] call EFUNC(logistics,setCargo);

        };
        default {
            [_vehicle, 
                GET_CONTAINER("droneair_ammo")
            ] call EFUNC(logistics,setCargo);
        };
    };
};

if (_vehicle isKindOf "UGV_01_base_F") then {
    switch (_vehicleType) do {
        case "B_T_UGV_01_medical_olive_F";
        case "B_W_UGV_01_medical_F";
        case "MED": {
            [_vehicle, 
                GET_CONTAINER("wheeled_medical")
            ] call EFUNC(logistics,setCargo);

        };
        default {
            [_vehicle, 
                GET_CONTAINER("vehicle_Wheeled")
            ] call EFUNC(logistics,setCargo);
        };
    };
};

