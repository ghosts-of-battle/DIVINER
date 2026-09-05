#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_opordAsk

Description:
    Decides whether the player who just spawned should be the one to post
    the current OPORD to C2 messaging, and tells them to if so. Server only;
    asked by every player's machine on spawn (FUNC(applyOnClient)).

    THE SERVER CANNOT POST. Messaging accepts a message only from a live
    player - srvSubmit checks isPlayer, and rightly, because a message with
    no sender has no mailbox and no call sign. So the OPORD goes up through
    the normal path, from the first ADMIN to spawn, once per mission. An
    admin, because that is who HQ is; once, because the second admin does
    not need to post it again.

    NOTHING TO POST IS THE COMMON CASE: no currentOpord, no messaging
    addon, or already posted.

Parameters:
    0: The unit <OBJECT>

Returns:
    Whether this unit was told to post <BOOL>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]]];

if (!isServer || isNull _unit) exitWith {false};
if (GVAR(opordPosted)) exitWith {false};
if ((GVAR(settings) getOrDefault ["currentOpord", ""]) isEqualTo "") exitWith {false};
if (isNil "ghostD_messaging_fnc_submit") exitWith {false};
if !([_unit] call ghostD_adminpanel_fnc_isAdmin) exitWith {false};

GVAR(opordPosted) = true;
[] remoteExec [QFUNC(opordPost), owner _unit];

INFO_1("%1 asked to post the OPORD",name _unit);
true
