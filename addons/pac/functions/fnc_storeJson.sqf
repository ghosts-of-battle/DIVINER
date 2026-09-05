#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_storeJson

Description:
    The whole player store as one JSON document - the backup format, and the
    export format, which are the same thing on purpose: what the .rpt catches
    at mission end is exactly what an admin's EXPORT puts on their clipboard,
    and FUNC(import) reads either.

        { "schemaVersion", "unitId", "serverId", "exportedAt",
          "players": { uid: record }, "sessions": [...], "windows": [...],
          "opords": {...}, "log": [...], "structureEdited": {...} }

    Server only - the store lives here.

Parameters:
    0: Pretty <BOOL> (optional, default false - one line, for the .rpt)

Returns:
    JSON <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_pretty", false, [false]]];

if (!isServer) exitWith {""};

private _doc = createHashMapFromArray [
    ["schemaVersion", PAC_SCHEMA],
    ["unitId", GVAR(settings) getOrDefault ["unitId", ""]],
    ["serverId", GVAR(settings) getOrDefault ["serverId", ""]],
    ["exportedAt", [] call FUNC(stamp)],
    ["players", GVAR(players)],
    ["sessions", GVAR(sessions)],
    ["windows", GVAR(windows)],
    ["opords", GVAR(opordArchive)],
    ["log", GVAR(log)],
    ["structureEdited", GVAR(structureEdited)]
];

[_doc, ["", "  "] select _pretty] call FUNC(toJson)
