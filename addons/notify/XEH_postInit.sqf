#include "script_component.hpp"

if (!hasInterface) exitWith {};

GVAR(slots) = [];      // [slotIndex, expireTime] for every slot in use
GVAR(queue) = [];      // [title, text, colour] waiting for a free slot
GVAR(pfh) = -1;

// Raised by FUNC(broadcast) on the receiving clients. Side filtering happens
// here rather than at the sender so one event serves everyone.
[QGVAR(post), {
    params ["_title", "_text", "_colour", ["_side", sideUnknown], ["_pos", []]];
    if (_side != sideUnknown && {side group ACE_player != _side}) exitWith {};
    [_title, _text, _colour, _pos] call FUNC(notify);
}] call CBA_fnc_addEventHandler;
