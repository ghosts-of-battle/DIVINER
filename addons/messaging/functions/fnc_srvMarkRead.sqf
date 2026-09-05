#include "script_component.hpp"
/*
 * Author: Ghost
 * Marks every message in a thread read by this player. Nothing is broadcast:
 * an unread count is the reader's own business and telling twenty clients that
 * somebody opened a thread is twenty messages for no gain.
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

private _uid = getPlayerUID _unit;
private _visible = [_unit] call FUNC(srvBoxesFor);

if !(_uid in (_thread get "participants") || {(_thread get "boxes") findIf {_x in _visible} >= 0}) exitWith {};

{
    private _message = GVAR(messages) getOrDefault [_x, createHashMap];
    if (_message isNotEqualTo createHashMap) then {
        (_message get "readBy") pushBackUnique _uid;
    };
} forEach (_thread get "messages");
