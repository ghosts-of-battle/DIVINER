#include "script_component.hpp"
/*
 * Author: 3Mydlo3
 * Function checks if player has disconnected before and allows him to teleport back
 *
 * Arguments:
 * 0: Player unit <OBJECT>
 * 1: Player UID <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, getPlayerUID player] call ghostD_back_to_game_fnc_handleConnected
 *
 * Public: No
 */

params ["_unit", "_uid"];

if (!isServer && {hasInterface}) exitWith {
    [QGVAR(handleConnected), _this] call CBA_fnc_serverEvent;

    nil
};

if ([_uid] call FUNC(hasDisconnected)) exitWith {
    INFO_1("%1 has disconnected previously, loading saved data.",name _unit);
    private _save = [_uid] call FUNC(getPlayerData);
    [QGVAR(handleTeleport), [_unit, _save], _unit] call CBA_fnc_targetEvent;

    // Spent. The save has been handed to the client that asked for it, and
    // leaving it in the store means a player who reconnects a second time is
    // offered the position they held on the FIRST disconnect - and that the
    // store grows for the life of the mission with entries nothing ever reads
    // again. FUNC(deletePlayerData) existed for this and was never called.
    [_uid] call FUNC(deletePlayerData);

    nil
};

nil
