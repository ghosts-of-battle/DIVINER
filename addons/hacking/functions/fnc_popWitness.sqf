#include "script_component.hpp"
/*
 * Author: Ghost
 * A hack on an internet pop, checked for witnesses. A pop is public
 * furniture in a settlement: any civilian close enough with eyes on the
 * hacker remembers it, and the settlement's hostility toward the hacker's
 * side goes up - through ALiVE's own ledger, on the server, never a rebuilt
 * one. Real comms towers carry no such audience; only tagged pops call this.
 *
 * Arguments:
 * 0: The hacker <OBJECT>
 * 1: The pop <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, _pop] call ghostD_hacking_fnc_popWitness
 */

params [["_player", objNull, [objNull]], ["_pop", objNull, [objNull]]];

if (isNull _player || {isNull _pop}) exitWith {};

private _witnesses = (_player nearEntities [["CAManBase"], POP_WITNESS_RANGE]) select {
    side _x isEqualTo civilian && {alive _x}
    && {([objNull, "VIEW"] checkVisibility [eyePos _x, eyePos _player]) > 0.3}
};
if (_witnesses isEqualTo []) exitWith {};

private _sideStr = str side group _player;
if !(_sideStr in ["WEST", "EAST", "GUER"]) exitWith {};

[QGVAR(popSeen), [getPosATL _pop, _sideStr]] call CBA_fnc_serverEvent;
["Hack", "You were seen.", [1, 0.3, 0.3, 1]] call EFUNC(notify,notify);
