#include "script_component.hpp"
/*
 * Author: YonV
 * Whose drone this is and what sort of airframe it is - the two things a
 * bearing and a range do not tell you.
 *
 * A contact on the scanner says to worry and which way to look; it does not
 * say whether that is somebody's recon quad or a gunship, which is the part
 * that decides what you do about it.
 *
 * Moved here from ctab_devices when cTab was dropped. It was always our code
 * and never cTab's - it only lived there because that is where the list it fed
 * was drawn.
 *
 * Arguments:
 * 0: The drone <OBJECT>
 *
 * Return Value:
 * Faction and airframe, ready to append to a row <STRING>
 *
 * Example:
 * [_uav] call ghostD_hacking_fnc_droneTag
 *
 * Public: Yes
 */

params [["_drone", objNull, [objNull]]];

if (isNull _drone) exitWith {""};

// The RUNTIME faction, not the config one: a re-crewed airframe still reads as
// its builder's faction in config, and who is flying it now is the part that
// decides whether you should be worried about it.
private _faction = faction _drone;
private _label = getText (configFile >> "CfgFactionClasses" >> _faction >> "displayName");
if (_label isEqualTo "") then {_label = _faction};
if (_label isEqualTo "") then {_label = str side _drone};

// StaticWeapon is tested BEFORE LandVehicle - it inherits from it, so the
// looser test on its own would call every mast and radar a ground vehicle.
private _type = switch (true) do {
    case (_drone isKindOf "Helicopter"): {"Rotary"};
    case (_drone isKindOf "Plane"): {"Fixed-wing"};
    case (_drone isKindOf "Ship"): {"Surface"};
    case (_drone isKindOf "StaticWeapon"): {"Static"};
    case (_drone isKindOf "LandVehicle"): {"Ground"};
    default {"Sensor"};
};

format ["%1 / %2", _label, _type]
