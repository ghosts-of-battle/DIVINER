#include "script_component.hpp"
/*
 * Author: YonV
 * Puts every player on the base-game voice (VON) channels his squad is on, and
 * takes him off the ones it is not.
 *
 * A RECONCILE, NOT A JOIN. It works out who SHOULD be on each channel from the
 * server's own picture - the player's group name, which is his squad's name -
 * and adds and removes only the difference against GVAR(vonMembers). So the
 * same call serves a fresh spawn, a respawn (the corpse is no longer a player
 * and comes off), a squad change, a JIP and a disconnect, and calling it when
 * nothing changed sends nothing. The clients raise QGVAR(vonSync) at those
 * moments so it is prompt; the postInit also runs it every VON_SYNC_INTERVAL
 * seconds, which is what catches a squad leader changing hands.
 *
 * WHO IS ON A NET. A planned net: every player on the mission's player side
 * (GVAR(vonSide)) whose squad the net lists. The fallback C2 net (no plan): the
 * leader of every squad - of every ORBAT squad when the ORBAT names any.
 *
 * Server only.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ghostD_players_fnc_vonSync
 *
 * Public: No
 */

if (!isServer || {isNil QGVAR(vonChannels)}) exitWith {};

private _side = missionNamespace getVariable [QGVAR(vonSide), west];
private _players = (allPlayers - entities "HeadlessClient_F") select {
    alive _x && {(side group _x) isEqualTo _side}
};

private _orbatSquads = [];
if (!isNil "ghostD_groups_fnc_orbat") then {
    _orbatSquads = (([] call ghostD_groups_fnc_orbat) # 0) apply {toUpper (_x # 0)};
};

{
    _x params ["_id", "_name", "_kind", "_squads", "_fallback"];

    private _want = if (_fallback) then {
        _players select {
            (leader group _x) isEqualTo _x
            && {_orbatSquads isEqualTo [] || {(toUpper groupId group _x) in _orbatSquads}}
        }
    } else {
        _players select {(toUpper groupId group _x) in _squads}
    };

    private _had = (GVAR(vonMembers) getOrDefault [_id, []]) select {!isNull _x};
    private _gone = _had - _want;
    private _new = _want - _had;

    if (_gone isNotEqualTo []) then {_id radioChannelRemove _gone};
    if (_new isNotEqualTo []) then {_id radioChannelAdd _new};
    GVAR(vonMembers) set [_id, _want];

    if (_gone isNotEqualTo [] || {_new isNotEqualTo []}) then {
        INFO_4("VON","net '%1' (channel %2): +%3 -%4",_name,_id,count _new,count _gone);
    };
} forEach GVAR(vonChannels);
