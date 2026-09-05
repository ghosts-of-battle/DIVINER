#include "script_component.hpp"
/*
 * Author: Ghost (from veteran29's module)
 * Forces the dead players of a side back into the fight.
 *
 * WAS A MODULE, IS A FUNCTION. Forcing a respawn is trigger-fired and one-shot -
 * it answers "when", not "where" - so under the four-class config rule it has no
 * business being a placeable module. A trigger's On Activation field is where a
 * mission maker was already going to express "now", and this is one line in it:
 *
 *     [west] call ghostD_respawn_fnc_forceRespawn;
 *
 * Only the DEAD are respawned. A living player is not interrupted, which is the
 * whole reason this is safe to fire from a trigger that may run more than once.
 *
 * Arguments:
 * 0: Side to respawn, sideUnknown for every side <SIDE> (optional)
 * 1: Filter - code taking [unit], returning whether to respawn them <CODE>
 *    (optional, default everyone)
 *
 * Return Value:
 * How many were respawned <NUMBER>
 *
 * Example:
 * [west, {alive (leader group (_this select 0))}] call ghostD_respawn_fnc_forceRespawn
 *
 * Public: Yes
 */

if (!isServer) exitWith {
    [QGVAR(forceRespawnRequest), _this] call CBA_fnc_serverEvent;
    0
};

params [["_side", sideUnknown, [sideUnknown]], ["_filter", {true}, [{}]]];

private _units = allPlayers select {
    !alive _x
    && {_side isEqualTo sideUnknown || {side group _x isEqualTo _side}}
    && {[_x] call _filter}
};

if (_units isEqualTo []) exitWith {0};

INFO_2("Respawning %2 dead player(s) of side %1:",_side,count _units);
{
    diag_log text format ["    %1", name _x];
} forEach _units;

[QGVAR(force), nil, _units] call CBA_fnc_targetEvent;

count _units
