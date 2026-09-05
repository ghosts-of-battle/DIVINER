#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_scannerToggle

Description:
    Takes the scanner out, or puts it away. Requires the item in hand luggage -
    unlike the tablet it needs no ISR flag: reading a warning lamp is not a
    trained skill.

Parameters:
    _unit : OBJECT - the player.

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_unit", objNull, [objNull]]];

if (!hasInterface) exitWith {};

// NOT OUTSIDE A MISSION. A handset overlay with no man carrying it is a
// widget on the main menu, which is exactly where this kept turning up -
// and there it cannot even be interacted with. Anything that can call this
// from the menu side (a keybind that survived, a settings handler, a stale
// per-frame tick) is refused here rather than cleaned up afterwards.
if (isNull player) exitWith {};

if (isNull _unit) then { _unit = player };

private _display = uiNamespace getVariable [QGVAR(scanner), displayNull];
if !(isNull _display) exitWith { [] call FUNC(scannerClose) };

if !([_unit] call FUNC(hasScanner)) exitWith {
    ["Scanner", "No signal scanner.", [1, 0.3, 0.3, 1]] call EFUNC(notify,notify);
};

// ON THE MISSION DISPLAY, NOT A TITLE LAYER - see the note at the top of
// scanner.hpp. Display 46 is created with the mission and destroyed with it by
// the engine, so the handset cannot survive onto the main menu; and it sits
// UNDER dialogs, so it no longer draws through the admin panel.
//
// The stored handle is display 46 itself, and every control keeps the idc it
// had - so FUNC(scannerLayout) and FUNC(scannerTick), which both work through
// `_display displayCtrl IDC_SCN_*`, did not have to change.
_display = findDisplay 46;
if (isNull _display) exitWith {};

// Creation order is paint order: the handset art first, then the readings onto it.
{
    _x params ["_class", "_idc"];
    _display ctrlCreate [_class, _idc];
} forEach [
    [QGVAR(scnBezel), IDC_SCN_BEZEL],
    [QGVAR(scnTitle), IDC_SCN_TITLE],
    [QGVAR(scnDroneI), IDC_SCN_ICO_DRONE],
    [QGVAR(scnDroneL), IDC_SCN_DRONE_L],
    [QGVAR(scnDroneV), IDC_SCN_DRONE_V],
    [QGVAR(scnJamI), IDC_SCN_ICO_JAM],
    [QGVAR(scnJamL), IDC_SCN_JAM_L],
    [QGVAR(scnJamV), IDC_SCN_JAM_V],
    [QGVAR(scnMeshI), IDC_SCN_ICO_MESH],
    [QGVAR(scnMeshL), IDC_SCN_MESH_L],
    [QGVAR(scnMeshV), IDC_SCN_MESH_V],
    [QGVAR(scnNetHead), IDC_SCN_NETHEAD],
    [QGVAR(scnNetI), IDC_SCN_ICO_NET],
    [QGVAR(scnNetL), IDC_SCN_NET_L],
    [QGVAR(scnNetV), IDC_SCN_NET_V],
    [QGVAR(scnAlarm), IDC_SCN_ALARM],
    [QGVAR(scnTimer), IDC_SCN_TIMER],
    [QGVAR(scnStatus), IDC_SCN_STATUS]
];

GVAR(scannerRaisedAt) = CBA_missionTime;
uiNamespace setVariable [QGVAR(scanner), _display];

[_display] call FUNC(scannerLayout);
GVAR(scannerPFH) = [FUNC(scannerTick), SCN_TICK, []] call CBA_fnc_addPerFrameHandler;
