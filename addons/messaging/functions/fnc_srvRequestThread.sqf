#include "script_component.hpp"
/*
 * Author: Ghost
 * Sends one thread's bodies to a player who is entitled to them. A player who
 * is not gets an empty answer rather than an error: refusing loudly would
 * confirm the thread exists, which is itself worth knowing.
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

private _fnc_deny = {
    [QGVAR(threadPush), [[], []], _unit] call CBA_fnc_targetEvent;
};

private _thread = GVAR(threads) getOrDefault [_threadId, createHashMap];
if (_thread isEqualTo createHashMap) exitWith {call _fnc_deny};

private _uid = getPlayerUID _unit;
private _visible = [_unit] call FUNC(srvBoxesFor);

if !(_uid in (_thread get "participants") || {(_thread get "boxes") findIf {_x in _visible} >= 0}) exitWith {
    call _fnc_deny
};

private _messages = [];
{
    private _message = GVAR(messages) getOrDefault [_x, createHashMap];
    if (_message isNotEqualTo createHashMap) then {
        _messages pushBack (_message toArray false);
    };
} forEach (_thread get "messages");

// Pairs, not [keys, values] - see FUNC(srvDeliver).
[QGVAR(threadPush), [_thread toArray false, _messages], _unit] call CBA_fnc_targetEvent;
