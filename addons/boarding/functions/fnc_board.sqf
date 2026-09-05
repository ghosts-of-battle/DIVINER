#include "script_component.hpp"
/*
 * Author: Ghost
 * Loads every player near a boarding point into cargo. SERVER SIDE.
 *
 * The presser is not the owner of the other players, and moveInCargo wants
 * the unit local - so each seating is sent to the machine that owns that
 * player rather than run here and hoped for.
 *
 * Nobody is teleported across the map: the range is the mission's, and a
 * player outside it is simply not this button's business. People already in a
 * vehicle are left where they are, because pulling a gunner out of his turret
 * to sit in the back of a truck is never what was meant.
 *
 * Arguments:
 * 0: The module <OBJECT>
 * 1: The player who pressed <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic, _player] call ghostD_boarding_fnc_board
 */

params [["_logic", objNull, [objNull]], ["_presser", objNull, [objNull]]];

if (!isServer || {isNull _logic}) exitWith {};

private _range = _logic getVariable [QGVAR(range), BOARD_RANGE_DEF];
private _at = getPosATL _logic;
private _sideOnly = (_logic getVariable ["sideOnly", 0]) == 0;
private _skipPresser = (_logic getVariable ["includePresser", 0]) == 1;

// FUNC(notify) is client-local and takes three arguments; the server telling
// one player something has to be sent to that player's machine.
private _fnc_tell = {
    params ["_to", "_text", "_colour"];
    if (isNull _to) exitWith {};
    ["Boarding", _text, _colour] remoteExec [QEFUNC(notify,notify), _to];
};

private _vehicles = [_logic] call FUNC(seatsFor);
if (_vehicles isEqualTo []) exitWith {
    [_presser, "No transport with room here.", [1, 0.3, 0.3, 1]] call _fnc_tell;
};

private _who = (allPlayers - entities "HeadlessClient_F") select {
    alive _x
    && {isNull objectParent _x}
    && {(_at distance2D _x) <= _range}
    && {!(_skipPresser && _x isEqualTo _presser)}
    && {!_sideOnly || {isNull _presser} || {side group _x isEqualTo side group _presser}}
};

if (_who isEqualTo []) exitWith {
    [_presser, "Nobody on foot in range.", [1, 0.3, 0.3, 1]] call _fnc_tell;
};

// Fill the nearest vehicle before moving to the next. emptyPositions is read
// again for each man rather than counted once up front: the seat a man takes
// is gone for the man behind him, and a stale count is how two people get
// sent to the same seat and one of them ends up standing.
private _seated = 0;
private _left = [];

{
    private _unit = _x;
    private _veh = _vehicles param [_vehicles findIf {(_x emptyPositions "cargo") > 0}, objNull];

    if (isNull _veh) then {
        _left pushBack _unit;
    } else {
        // where the unit is local - moveInCargo on a remote player does not
        // reliably take
        [_unit, _veh] remoteExec ["moveInCargo", _unit];
        _seated = _seated + 1;
    };
} forEach _who;

// Told to the people it happened to, not to the whole server: a section
// boarding in one town is nobody else's business.
{
    [_x, format ["%1 aboard.", _seated], [0.914, 0.651, 0.235, 1]] call _fnc_tell;
} forEach (_who - _left);

if (_left isNotEqualTo []) then {
    [_presser, format ["%1 could not be seated - no room left.", count _left],
        [1, 0.3, 0.3, 1]] call _fnc_tell;
};

INFO_2("boarding point loaded %1, %2 left standing",_seated,count _left);
