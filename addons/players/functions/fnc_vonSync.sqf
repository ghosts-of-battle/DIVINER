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
 * (GVAR(vonSide)) the net matches - his squad is listed, his role is listed (his
 * YMF_role, a "_t" testing copy counting as its base id) or he holds a listed
 * PAC skill (ghostD_pac_skillIds) - and only the FIRST net of each kind that
 * matches him, in plan order (2026-10-21: one C2 net and one A2G net a man, the
 * same rule the JMSB voice addon uses). Nobody is on C2 just for existing once a
 * plan is written. The fallback C2 net (no plan): the leader of every squad - of
 * every ORBAT squad when the ORBAT names any.
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

// Whether a planned net takes a player: his squad, his role or a skill of his.
private _fnc_matches = {
    params ["_unit", "_squads", "_roles", "_skills"];
    if ((toUpper groupId group _unit) in _squads) exitWith {true};
    private _role = _unit getVariable [VON_ROLE_VAR, ""];
    if !(_role isEqualType "") then {_role = ""};
    _role = toLower trim _role;
    private _suffix = count VON_ROLE_TEST_SUFFIX;
    if (count _role > _suffix && {(_role select [count _role - _suffix]) isEqualTo VON_ROLE_TEST_SUFFIX}) then {
        _role = _role select [0, count _role - _suffix];
    };
    if (_role isNotEqualTo "" && {_role in _roles}) exitWith {true};
    private _held = _unit getVariable [VON_SKILLS_VAR, []];
    if !(_held isEqualType []) then {_held = []};
    (_held findIf {_x isEqualType "" && {(toLower trim _x) in _skills}}) >= 0
};

// THE FIRST NET OF EACH KIND that takes him: [unit, kind] -> channel id.
private _firstOf = createHashMap;
{
    _x params ["_id", "", "_kind", "_squads", "_fallback", ["_roles", []], ["_skills", []]];
    if (_fallback) then {continue};
    private _netId = _id;
    {
        private _key = [getPlayerUID _x, _kind];
        if (_key in _firstOf) then {continue};
        if ([_x, _squads, _roles, _skills] call _fnc_matches) then {_firstOf set [_key, _netId]};
    } forEach _players;
} forEach GVAR(vonChannels);

{
    _x params ["_id", "_name", "_kind", "_squads", "_fallback"];

    private _want = if (_fallback) then {
        _players select {
            (leader group _x) isEqualTo _x
            && {_orbatSquads isEqualTo [] || {(toUpper groupId group _x) in _orbatSquads}}
        }
    } else {
        _players select {(_firstOf getOrDefault [[getPlayerUID _x, _kind], -1]) isEqualTo _id}
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
