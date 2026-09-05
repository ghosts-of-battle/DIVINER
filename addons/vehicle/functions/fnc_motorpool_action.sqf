#include "script_component.hpp"
/*
    File: fn_motorpool_action.sqf
    Author: YonV/Ghost
    Description: The big button. On a category tab it spawns the selected
        vehicle on the pad - same treatment the old spawner gave it (cargo
        emptied, toolkit and wheels aboard, ledger on the controller so
        every client's remove list agrees) - then applies the chosen paint
        and every fitting toggled ON. On the SPAWNED tab it removes the
        selected vehicle, crew permitting.

    Example:
    [] call ghostD_vehicle_fnc_motorpool_action;
*/

private _d = uiNamespace getVariable ["YMF_motorpool_dlg", displayNull];
if (isNull _d) exitWith {};

(uiNamespace getVariable ["YMF_motorpool_ctx", [objNull, objNull]]) params ["_controller", "_pad"];
private _lnb = _d displayCtrl 130;
private _row = lnbCurSelRow _lnb;
if (_row < 0) exitWith {};

private _data = _lnb lnbData [_row, 0];

// ---------------------------------------------------------------- remove --
if ((_data select [0, 2]) isEqualTo "s:") exitWith {
    private _spawned = _controller getVariable ["YMF_spawnedVehicles", []];
    private _entry = _spawned param [parseNumber (_data select [2]), []];
    _entry params [["_veh", objNull]];
    if (isNull _veh) exitWith {[] call ghostD_vehicle_fnc_motorpool_fill};

    // A DRONE'S CREW IS ITS AUTOPILOT, not a person. Take it out first, or
    // every UGV on the pad is "still occupied" forever. A player flying the
    // drone is never aboard it - UAV control is remote - so nobody is lost.
    if (getNumber (configOf _veh >> "isUav") > 0) then {
        {if (!isPlayer _x) then {deleteVehicle _x}} forEach crew _veh;
    };
    if (((fullCrew _veh) select {alive (_x select 0)}) isEqualTo []) then {
        _spawned = _spawned select {(_x select 0) isNotEqualTo _veh};
        _controller setVariable ["YMF_spawnedVehicles", _spawned, true];
        deleteVehicle _veh;
    } else {
        ["Motorpool", "Could not delete vehicle, there are still people in the vehicle.", NOTE_BAD] call EFUNC(notify,notify);
    };
    [] call ghostD_vehicle_fnc_motorpool_fill;
};

// ----------------------------------------------------------------- spawn --
if (count (_pad nearEntities 5) != 0) exitWith {
    ["Motorpool", "Could not spawn vehicle, there is already a vehicle on the spawn position.", NOTE_BAD] call EFUNC(notify,notify);
};

private _veh = createVehicle [_data, getPosATL _pad, [], 0, "CAN_COLLIDE"];

// The heading from the pad's init line when one was given; the pad's own
// Eden facing otherwise. Set before anyone boards - an aircraft that
// spawns nosed into the hangar is re-parked here, not by hand.
private _dir = _controller getVariable ["YMF_motorpool_dir", -1];
if (_dir < 0) then {_dir = getDir _pad};
_veh setDir _dir;

// A DRONE COMES WITH ITS OPERATOR. createVehicle hands a UAV over empty, and
// an empty UAV is a prop - nothing for a terminal to connect to, nothing to
// drive it. The AI crew its config names (B_UAV_AI, or the mod's own) is what
// makes it a drone, and createVehicleCrew reads that from the config. The
// vehicle was created here, so it is local here, which is what the command
// needs.
if (getNumber (configFile >> "CfgVehicles" >> _data >> "isUav") > 0) then {
    createVehicleCrew _veh;
};

clearItemCargoGlobal _veh;
clearBackpackCargoGlobal _veh;
clearWeaponCargoGlobal _veh;
clearMagazineCargoGlobal _veh;
_veh addItemCargoGlobal ["ToolKit", 1];
if (_veh isKindOf "LandVehicle") then {
    ["ACE_Wheel", _veh] call ace_cargo_fnc_loadItem;
    ["ACE_Wheel", _veh] call ace_cargo_fnc_loadItem;
};

private _spawned = _controller getVariable ["YMF_spawnedVehicles", []];
_spawned pushBack [_veh, name player, ""];
_controller setVariable ["YMF_spawnedVehicles", _spawned, true];

// The cosmetic code blocks read `_vehicle` from this scope.

private _paintIdx = lbCurSel (_d displayCtrl 164);
private _paints = uiNamespace getVariable ["YMF_motorpool_paints", []];
if (_paintIdx > 0) then {
    call ((_paints param [_paintIdx - 1, ["", {}]]) select 1);
};

{
    _x params ["", "_code", "_on"];
    if (_on) then {call _code};
} forEach (uiNamespace getVariable ["YMF_motorpool_fits", []]);

["Motorpool", format ["%1 is on the pad.", getText (configFile >> "CfgVehicles" >> _data >> "displayName")], NOTE_GOOD] call EFUNC(notify,notify);

// THE SPAWN CLOSES THE SCREEN (user, 2026-08-29: "set the interface to close
// when vehicle spawns"). The vehicle is on the pad and the next thing the
// player does is walk to it, not read a list; the notify above is the
// receipt. REMOVE, above, stays open - it is a list operation and the list is
// what changed.
closeDialog 0;
