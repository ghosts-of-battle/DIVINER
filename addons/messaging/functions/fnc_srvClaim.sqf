#include "script_component.hpp"
/*
 * Author: Ghost
 * Claims a task thread. First come, first served and never taken back by
 * somebody else - two medics both answering the same CASEVAC is the failure
 * this exists to stop, and a claim that anyone can steal does not stop it.
 *
 * The claimant may release their own claim by claiming again.
 *
 * Arguments (CBA event):
 * 0: Player <OBJECT>
 * 1: Thread id <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]], ["_threadId", "", [""]]];

if (!isServer || {isNull _unit} || {!isPlayer _unit}) exitWith {};

private _thread = GVAR(threads) getOrDefault [_threadId, createHashMap];
if (_thread isEqualTo createHashMap) exitWith {};
if (_thread get "closed") exitWith {};

private _uid = getPlayerUID _unit;
private _visible = [_unit] call FUNC(srvBoxesFor);

if !(_uid in (_thread get "participants") || {(_thread get "boxes") findIf {_x in _visible} >= 0}) exitWith {};

private _held = _thread get "claimedBy";
if (_held != "" && _held != _uid) exitWith {
    [QGVAR(reject), ["CLAIM", "somebody already has that one"], _unit] call CBA_fnc_targetEvent;
};

private _now = ["", _uid] select (_held == "");
_thread set ["claimedBy", _now];
_thread set ["lastActivity", CBA_missionTime];
(_thread get "participants") pushBackUnique _uid;

[QGVAR(threadUpdated), [_threadId, _thread get "status"]] call CBA_fnc_globalEvent;

// Everyone who can see it needs the row again - the claim is the single most
// useful thing in an index and a stale one is worse than none.
private _boxes = _thread get "boxes";
{
    private _player = _x;
    private _visibleTo = [_player] call FUNC(srvBoxesFor);
    if (_boxes findIf {_x in _visibleTo} >= 0) then {
        [_player] call FUNC(srvRequestIndex);
    };
} forEach allPlayers;
