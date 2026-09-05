#include "script_component.hpp"
/*
 * Author: YonV
 * Applies another vehicle class's hiddenSelectionsTextures to a vehicle (paint
 * scheme donor). The donor class may contain %1, which is replaced with the
 * vehicle's variant token from its classname (mover/ammo/box/fuel/repair/
 * medical/transport/covered/cargo/flatbed) so one entry can cover a family
 * of variants (e.g. "EF_B_Truck_01_%1_MJTF_Wdl").
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Donor classname or pattern <STRING>
 *
 * Return Value:
 * applied <BOOL>
 *
 * Example:
 * [_vehicle, "B_W_Truck_01_ammo_F"] call ghostD_vehicle_fnc_applyClassTextures;
 * [_vehicle, "EF_B_Truck_01_%1_MJTF_Wdl"] call ghostD_vehicle_fnc_applyClassTextures;
 *
 * Public: No
 */

params [
    ["_vehicle", objNull, [objNull]],
    ["_donorClass", "", [""]]
];

if (isNull _vehicle || _donorClass isEqualTo "") exitWith {false};

if ("%1" in _donorClass) then {
    private _type = toLower typeOf _vehicle;
    private _variant = "";
    {
        if ((_type find ("_" + _x + "_")) > -1) exitWith {_variant = _x};
    } forEach ["mover", "ammo", "box", "fuel", "repair", "medical", "transport", "covered", "cargo", "flatbed"];
    _donorClass = format [_donorClass, _variant];
};

private _config = configFile >> "CfgVehicles" >> _donorClass;
if (!isClass _config) exitWith {
    [
        "Vehicle",
        format ["This paint scheme is not available for %1 (no class %2).", getText (configOf _vehicle >> "displayName"), _donorClass],
        NOTE_BAD
    ] call GHOSTFUNC(notify,notify);
    playSound "addItemFailed";
    false
};

private _donorTextures = getArray (_config >> "hiddenSelectionsTextures");
if (_donorTextures isEqualTo []) exitWith {false};

private _pairs = [];
{
    _pairs pushBack [_forEachIndex, _x];
} forEach _donorTextures;

[_vehicle, _pairs] call EFUNC(vehicle,applyTextures);
true
