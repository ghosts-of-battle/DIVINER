#include "script_component.hpp"
/*
 * Author: YonV
 * The local player's base-game voice (VON) channel, as a line short enough for
 * a table column - the VON answer for ghostD_tacpad_apps_fnc_radioState.
 *
 * THE GROUP CHANNEL IS THE TEAM NET, so on it the line is the squad's team net
 * name (FUNC(vonTeamNet) - the squad's own name when the plan gives none). A
 * custom channel is named for its net, from the server's GVAR(vonLabels); the
 * engine's other channels by their own names.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Channel, "" with no player or outside VON mode <STRING>
 *
 * Example:
 * [] call ghostD_players_fnc_vonState
 *
 * Public: No
 */

if (!hasInterface || {!EGVAR(common,von)} || {isNull player}) exitWith {""};

private _channel = currentChannel;

if (_channel > VON_CH_DIRECT) exitWith {
    private _id = _channel - VON_CUSTOM_OFFSET;
    private _row = (missionNamespace getVariable [QGVAR(vonLabels), []]) select {(_x # 0) isEqualTo _id};
    if (_row isEqualTo []) exitWith {format ["CH %1", _id]};
    (_row # 0) # 1
};

switch (_channel) do {
    case VON_CH_GROUP: {[groupId group player] call FUNC(vonTeamNet)};
    case VON_CH_GLOBAL: {"GLOBAL"};
    case VON_CH_SIDE: {"SIDE"};
    case VON_CH_COMMAND: {"COMMAND"};
    case VON_CH_VEHICLE: {"VEHICLE"};
    case VON_CH_DIRECT: {"DIRECT"};
    default {""};
}
