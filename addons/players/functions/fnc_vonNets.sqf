#include "script_component.hpp"
/*
 * Author: YonV
 * The base-game voice (VON) plan in effect: one entry per custom radio channel.
 *
 * READ OFF THE RADIO PLAN, LIKE THE ACRE AND TFAR TABLES. ghostFR_radio_vonNets
 * is [[netName, "c2" | "a2g", [squadName, ...], [roleId, ...], [skillId, ...]],
 * ...], written from the unit's <unit>.radio document by
 * ghostD_pac_fnc_radioApply (or by a mission's own config_radio.hpp). A row
 * without a name is dropped, a kind that is not one of VON_KINDS reads as "c2",
 * squad names are compared upper case, role and skill ids lower case.
 *
 * ROLES AND SKILLS (2026-10-21, user: C2 for every team lead, assistant team
 * lead and the HQ; A2G for everyone with the JFO skill). A net's members are the
 * squads it lists, plus anyone whose role it lists (a role's "_t" testing copy
 * counts as its base id), plus anyone holding a skill it lists. An old row of
 * three columns has no roles and no skills.
 *
 * NO PLAN IS A PLAN TOO. With nothing written, the answer is one C2 net holding
 * every squad leader, and the fallback flag is set - which tells the client side
 * (FUNC(vonClient)) to leave the engine's channels exactly as the mission has
 * them.
 *
 * The engine has ten custom channels, so a plan longer than VON_MAX_NETS is cut
 * and the cut is logged.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * [[[netName, kind, [SQUAD, ...], [roleid, ...], [skillid, ...]], ...], fallback] <ARRAY>
 *
 * Example:
 * ([] call ghostD_players_fnc_vonNets) params ["_nets", "_fallback"]
 *
 * Public: No
 */

private _plan = missionNamespace getVariable ["ghostFR_radio_vonNets", []];
if !(_plan isEqualType []) then {_plan = []};

private _nets = [];
{
    if !(_x isEqualType []) then {continue};
    _x params [["_name", "", [""]], ["_kind", VON_FALLBACK_KIND, [""]], ["_squads", [], [[]]], ["_roles", [], [[]]], ["_skills", [], [[]]]];
    _name = trim _name;
    if (_name isEqualTo "") then {continue};
    _kind = toLower trim _kind;
    if !(_kind in VON_KINDS) then {_kind = VON_FALLBACK_KIND};
    _nets pushBack [
        _name, _kind,
        (_squads select {_x isEqualType ""}) apply {toUpper trim _x},
        ((_roles select {_x isEqualType ""}) apply {toLower trim _x}) select {_x isNotEqualTo ""},
        ((_skills select {_x isEqualType ""}) apply {toLower trim _x}) select {_x isNotEqualTo ""}
    ];
} forEach _plan;

if (count _nets > VON_MAX_NETS) then {
    // said once per machine - the client side asks this every few seconds
    if (missionNamespace getVariable [QGVAR(vonCutSaid), false]) exitWith {};
    GVAR(vonCutSaid) = true;
    WARNING_2("VON","the plan names %1 nets; the engine has %2 custom channels - the rest are dropped",count _nets,VON_MAX_NETS);
};
if (count _nets > VON_MAX_NETS) then {_nets resize VON_MAX_NETS};

if (_nets isEqualTo []) exitWith {
    [[[VON_FALLBACK_NET, VON_FALLBACK_KIND, [], [], []]], true]
};

[_nets, false]
