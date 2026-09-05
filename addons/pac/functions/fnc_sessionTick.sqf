#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_sessionTick

Description:
    The heartbeat. Every PAC_HEARTBEAT seconds the server moves lastSeenAt
    forward on every open session whose player is still here. Its whole
    purpose is the server that dies without a disconnect: those rows keep an
    empty leftAt, and lastSeenAt is then within a minute of when the player
    was actually last on.

    A player found on the server with no open session - the connect event was
    missed somehow - gets one now, so attendance is never silently short.

    IT WRITES NOTHING (user, 2026-09-05: "write only on edit"). The rows are
    kept in memory and go out with the next save something else asks for -
    a connect, a disconnect, an admin's edit, a window stopped, the mission
    ending. A server that dies between two of those loses the minutes since
    the last one on its open sessions, and that is the trade.

    Runs from a plain spawn loop in XEH_postInit; vanilla plumbing.

Parameters:
    None

Returns:
    How many sessions were touched <NUMBER>

Author:
    YonV
---------------------------------------------------------------------------- */

if (!isServer) exitWith {0};

private _now = [] call FUNC(stamp);
private _touched = 0;
private _open = [];

{
    if ((_x # 4) isEqualTo "") then {_open pushBack (_x # 0)};
} forEach GVAR(sessions);

{
    private _uid = getPlayerUID _x;
    if (_uid isEqualTo "") then {continue};

    if (_uid in _open) then {
        {
            if ((_x # 0) isEqualTo _uid && {(_x # 4) isEqualTo ""}) then {_x set [3, _now]};
        } forEach GVAR(sessions);
    } else {
        [_uid, name _x] call FUNC(sessionStart);
    };
    _touched = _touched + 1;
} forEach (allPlayers select {isPlayer _x});

_touched
