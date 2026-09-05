#include "script_component.hpp"
/*
 * Author: 3Mydlo3
 * Function terminates spectator for given player
 *
 * Arguments:
 * 0: player unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call ghostD_spectator_fnc_stop
 *
 * Public: No
 */

params [["_player", player]];

// STOP, not start - the copy-paste from fnc_start inverted the remote
// path's meaning: "terminate spectator for that player" STARTED it there.
if (!(local _player)) exitWith {[QGVAR(stop), _this, _player] call CBA_fnc_targetEvent};

["Terminate"] call BIS_fnc_EGSpectator;
WARNING("Stopping spectator!");

nil
