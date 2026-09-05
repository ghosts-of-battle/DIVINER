#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_debugReply

Description:
    Prints a debug-command reply to the caller. System chat, never the
    ghost_notify stack - the stack is for players, this is for whoever is
    testing.

Parameters:
    _text   : STRING - the line.
    _target : OBJECT - who to tell. Optional, default the local player.

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_text", "", [""]], ["_target", objNull, [objNull]]];

if (isNull _target || {_target isEqualTo player}) exitWith {
    if (hasInterface) then { systemChat format ["[ghost] %1", _text] };
};

[_text, objNull] remoteExec [QFUNC(debugReply), _target];
