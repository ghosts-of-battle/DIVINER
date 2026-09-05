#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_storeLoad

Description:
    Reads the store out of the server's profileNamespace - always the store;
    the service (boot step 5) may replace it with the database's copy.

    SERVER ONLY, AND THAT IS THE WHOLE SECURITY MODEL. Clients never write
    player data - they ask the server through remoteExec and the server
    re-checks who is asking. A client that loaded this would be reading its own
    profile and believing it, which is how a roster gets rewritten by whoever
    edits a file on their own machine.

    FOUR KEYS, NAMED BY THE HANDOFF. They are the backup format as much as the
    runtime one - an export is these keys, an import writes them back - so they
    are not ours to rename for tidiness.

    A MISSING STORE IS A NEW UNIT, not a fault. Everything comes back empty and
    the first player to connect is seeded. The one thing that warns is a
    schemaVersion from the future: that is a store written by a build newer than
    this one, and quietly working on it is how data gets lost.

    NOTHING IS TRUSTED BY NAME ALONE. A profile edited by hand, or written by a
    build that kept something else under the key, is refused by type rather than
    handed to the roster - a hashmap is expected and an array is not it.

Parameters:
    None

Returns:
    None

Author:
    YonV
---------------------------------------------------------------------------- */

if (!isServer) exitWith {};

private _fnc_read = {
    params ["_key", "_default"];
    private _v = profileNamespace getVariable [_key, _default];
    if !(_v isEqualType _default) exitWith {
        WARNING_1("store key %1 holds the wrong type - starting it empty",_key);
        _default
    };
    _v
};

GVAR(players) = [PAC_KEY_PLAYERS, createHashMap] call _fnc_read;
GVAR(sessions) = [PAC_KEY_SESSIONS, []] call _fnc_read;
GVAR(windows) = [PAC_KEY_WINDOWS, []] call _fnc_read;
GVAR(meta) = [PAC_KEY_META, createHashMap] call _fnc_read;
GVAR(opordArchive) = [PAC_KEY_OPORDS, createHashMap] call _fnc_read;
GVAR(log) = [PAC_KEY_LOG, []] call _fnc_read;

// A STORE THAT COMES UP EMPTY WHEN IT WAS NOT IS A LOST STORE, and the worst
// thing to do with one is carry on: players joining are seeded fresh, it looks
// healthy, and the last good copy is forgotten. So it goes read-only, loudly,
// until an admin restores from a backup or an export - or clears it on purpose.
private _hadPlayers = GVAR(meta) getOrDefault ["players", 0];
if (_hadPlayers > 0 && {count GVAR(players) isEqualTo 0}) then {
    GVAR(readOnly) = true;
    WARNING_1("STORE LOOKS LOST: the last save held %1 player(s) and this load found none. Read-only until restored (RESTORE FULL from a backup) or cleared.",_hadPlayers);
};

// ---- meta ------------------------------------------------------------------
// unitId and serverId are stamped from settings on every load rather than kept:
// they live in the mission file and the file is the authority. A box whose
// serverId changed has changed, and the store should say so.
private _was = GVAR(meta) getOrDefault ["schemaVersion", PAC_SCHEMA];

if (_was > PAC_SCHEMA) then {
    WARNING_2("store is schema %1 and this build reads %2 - refusing to write over it",_was,PAC_SCHEMA);
    GVAR(readOnly) = true;
} else {
    GVAR(readOnly) = false;
    if (_was < PAC_SCHEMA) then {
        INFO_2("store is schema %1, migrating to %2",_was,PAC_SCHEMA);
    };
};

GVAR(meta) set ["schemaVersion", PAC_SCHEMA];
GVAR(meta) set ["unitId", GVAR(settings) getOrDefault ["unitId", ""]];
GVAR(meta) set ["serverId", GVAR(settings) getOrDefault ["serverId", ""]];

// ---- the operator shape ----------------------------------------------------
// Every record gets every key FUNC(recordFields) names, an operator id and
// an enlistment date - a store written by an older PAC reads like today's.
[] call FUNC(recordUpgrade);

// ---- orphan check ----------------------------------------------------------
// A player pointing at a rank, role, skill or award the structure no longer has
// is FLAGGED AND KEPT, never dropped - a renamed class in a config file is not
// a reason to lose somebody's record, and the admin panel is where it gets
// fixed. The count is said once here so a broken structure is noticed at start
// rather than by a player finding themselves rankless.
private _orphans = [];

{
    private _uid = _x;
    private _rec = _y;

    {
        _x params ["_field", "_section"];
        private _id = _rec getOrDefault [_field, ""];
        if (_id isNotEqualTo "" && {!(_id in (GVAR(structure) getOrDefault [_section, createHashMap]))}) then {
            _orphans pushBack [_uid, _field, _id];
        };
    } forEach [["rankId", "ranks"], ["roleId", "roles"], ["statusId", "statuses"]];

    {
        if !(_x in (GVAR(structure) getOrDefault ["skills", createHashMap])) then {
            _orphans pushBack [_uid, "skillIds", _x];
        };
    } forEach (_rec getOrDefault ["skillIds", []]);
} forEach GVAR(players);

GVAR(orphans) = _orphans;

if (_orphans isNotEqualTo []) then {
    WARNING_1("%1 player reference(s) point at structure ids that no longer exist - see the admin panel",count _orphans);
};

INFO_3("store: %1 player(s), %2 session(s), %3 window(s)",count GVAR(players),count GVAR(sessions),count GVAR(windows));

nil
