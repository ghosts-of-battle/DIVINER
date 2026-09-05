#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_storeAdopt

Description:
    Takes a store document - the shape FUNC(storeJson) writes, read back
    from a file or a service - and makes it the store. Server only.

    THE DOCUMENT IS THE STORE. Whatever was in memory before - the profile
    copy, the file copy, a record seeded for somebody who connected during
    the service wait - is replaced, not merged. A merge would keep a record
    the document had lost on purpose (a player removed on another server)
    and bring him back from this box's stale copy; a replace lets the source
    of truth be one. A player on the server with no open session afterwards
    gets one from the heartbeat within a minute, and his record is seeded
    again at spawn if the document did not have him. A document that is the
    wrong shape is refused whole - half a store is worse than the old one.

Parameters:
    0: The document <HASHMAP>

Returns:
    Whether it was adopted <BOOL>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_doc", createHashMap, [createHashMap]]];

if (!isServer) exitWith {false};

private _p = _doc getOrDefault ["players", createHashMap];
private _s = _doc getOrDefault ["sessions", []];
private _w = _doc getOrDefault ["windows", []];
private _o = _doc getOrDefault ["opords", createHashMap];
if !(_p isEqualType createHashMap && _s isEqualType [] && _w isEqualType [] && _o isEqualType createHashMap) exitWith {false};

GVAR(players) = _p;
GVAR(sessions) = _s;
GVAR(windows) = _w;
GVAR(opordArchive) = _o;
private _l = _doc getOrDefault ["log", []];
GVAR(log) = [[], _l] select (_l isEqualType []);
[] call FUNC(recordUpgrade);

private _from = _doc getOrDefault ["exportedAt", "?"];
INFO_3("store adopted: %1 player(s), %2 session(s), exported %3",count _p,count _s,_from);

true
