#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_adminRecv

Description:
    The answer to FUNC(adminGet), arriving on the admin's machine. Keeps the
    record and hands it to the one dialog, which redraws the player page if
    that is what is waiting for it.

Parameters:
    0: UID <STRING>
    1: The record <HASHMAP>

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_uid", "", [""]], ["_rec", createHashMap, [createHashMap]]];

if (!hasInterface) exitWith {};

GVAR(editUid) = _uid;
GVAR(editRecord) = _rec;
// the player page asked for it under this name (FUNC(uiAsk))
["record:" + _uid, _rec] call FUNC(uiRecv);
