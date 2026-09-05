#include "script_component.hpp"
/*
 * Author: Reeveli
 * The move itself: fade out, put the man down at the point, fade back in.
 *
 * Arguments:
 * 0: Unit - the local player <OBJECT>
 * 1: Destination object <OBJECT>
 *
 * Return Value: None
 *
 * Example:
 * [player, _object] call ghostD_teleport_fnc_teleport
 *
 * Public: Yes
 */

params [
    ["_unit", player, [objNull]],
    ["_object", objNull, [objNull]]
];

if (!hasInterface) exitWith {};
if (isNull _object) exitWith {};

if (player isNotEqualTo _unit) exitWith {
    WARNING("teleport was asked for somebody who is not the local player");
};

// The cut fades the screen; the words go to the notification panel.
["Teleport", "You are being moved.", [ARR_4(0.871,0.361,0.188,1)]] call EFUNC(notify,notify);
cutText ["", "BLACK", 1];
player enableSimulation false;

[{
    params ["_object"];

    // SIMULATION COMES BACK WHATEVER HAPPENS. It is switched off above, and
    // a destination deleted during the fade used to leave the player frozen
    // for the rest of the mission with no way out.
    if (isNull _object) exitWith {
        player enableSimulation true;
        cutText ["", "BLACK IN", 1, true];
        ["Teleport", "The destination is gone.", [ARR_4(1,0.3,0.3,1)]] call EFUNC(notify,notify);
    };

    // ASL so the destination's own height is kept - setPos snaps to the
    // surface, which drops you in the water beside a ship instead of onto its
    // deck. The scatter stops a section stacking inside one man.
    private _p = getPosASL _object;
    player setPosASL [(_p # 0) + (random 6 - 3), (_p # 1) + (random 6 - 3), (_p # 2) + 0.5];
}, [_object], GVAR(actionTime) * 0.5] call CBA_fnc_waitAndExecute;

[{
    cutText ["", "BLACK IN", 2, true];
    player enableSimulation true;
}, [], GVAR(actionTime)] call CBA_fnc_waitAndExecute;
