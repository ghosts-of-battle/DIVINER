#include "script_component.hpp"
/*
 * Author: Ghost
 * The net name of the platoon a squad belongs to, from the unit's ORBAT.
 *
 * WHY THIS EXISTS. The MR plan is written per PLATOON, not per squad (user,
 * 2026-09-01: "4 plt nets ever one sees then squad net only a squad sees") -
 * four channels for a task force of fourteen elements. fn_getRadioChannel
 * matches a channel by name against the group id, so "NOMAD 2-3" finds nothing
 * and would land on the detachment default; this is what it asks next.
 *
 * THE ORBAT ALREADY SAYS WHICH SQUADS ARE IN WHICH PLATOON - the platoon rows
 * the role screen draws its tabs from - so a platoon that wants a radio net
 * adds one property to the tab it already has. Read through
 * ghostD_groups_fnc_orbat, so the rows are the database's when TAC//PAC holds
 * the ORBAT there and the mission's Dynamic_Groups otherwise.
 *
 * TWO TABLES, ASKED IN ORDER. The shared radio nets first (Dynamic_Groups >>
 * RadioNets, or the ORBAT's radioNets), because a net can cross a platoon
 * boundary - GROUND 1 is a rifle squad and the crew that carries it, which is
 * one element of 1st PLT and one of 2nd - and a platoon tab cannot say that.
 * Platoons second, for the squads no finer table names.
 *
 * A platoon with no net, a unit with no platoons, or a squad in no platoon all
 * answer "" and leave the caller on its default.
 *
 * Arguments:
 * 0: Squad name <STRING> - the group id, any case
 *
 * Return Value:
 * Net name, upper-cased, or "" <STRING>
 *
 * Example:
 * ["NOMAD 2-3"] call ghostD_players_fnc_platoonNet  // "NOMAD"
 *
 * Public: No
 */

params [["_squad", "", [""]]];

if (_squad isEqualTo "") exitWith {""};
if (isNil "ghostD_groups_fnc_orbat") exitWith {""};
_squad = toUpper _squad;

([] call ghostD_groups_fnc_orbat) params ["", "_platoons", "_radioNets"];

// rows, the index of the net in a row, the index of the squad list in a row
private _fnc_lookup = {
    params ["_rows", "_netAt", "_squadsAt"];
    private _hit = "";
    {
        private _net = _x param [_netAt, ""];
        if (!(_net isEqualType "") || _net isEqualTo "") then {continue};
        private _squads = _x param [_squadsAt, []];
        if !(_squads isEqualType []) then {continue};
        if (_squad in (_squads apply {toUpper _x})) exitWith {_hit = toUpper _net};
    } forEach _rows;
    _hit
};

private _net = [_radioNets, 1, 2] call _fnc_lookup;
if (_net isEqualTo "") then {_net = [_platoons, 3, 4] call _fnc_lookup};

_net
