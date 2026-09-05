#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_adminRecv

Description:
    The answer to FUNC(adminGet), arriving on the admin's machine. Keeps the
    record and, if the PAC page is open on that player, fills it.

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

[] call FUNC(panelFill);
[] call FUNC(manageFill);
