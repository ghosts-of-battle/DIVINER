#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_publish

Description:
    Sends the roster to every client, as one flat readable array.

    CLIENTS READ, CLIENTS NEVER WRITE. This is the only direction player data
    travels outward. An edit goes the other way through remoteExec to a
    server-side function that re-checks who is asking - a client that could
    write the roster is a client that owns the roster.

    IT IS NOT THE STORE. Notes and saved loadouts stay on the server: a note is
    written by an admin ABOUT a player and is nobody else's business, and a
    loadout is several kilobytes per role per person that no roster row needs.
    What goes out is what a roster row and a record page draw.

    ONE VARIABLE, WHOLE, WHICH IS PHASE 1's ANSWER. The handoff puts deltas in
    phase 2 and says so; sending the lot on every change is wrong for sixty
    players and completely fine for the size a unit actually runs, and the shape
    that replaces it wants a client that already works to compare against.

    PUBLISHED ON CHANGE, NOT ON A TIMER. Nothing changes the roster except an
    admin action or a connect, and both call this. A poll would be a broadcast a
    second for a list that changes twice an evening.

Parameters:
    None

Returns:
    None

Author:
    YonV
---------------------------------------------------------------------------- */

if (!isServer) exitWith {};

private _out = [];

// Own attendance, all time, per player: [minutes, joins]. Totalled here so a
// client can show "time on" without ever holding the sessions. Open rows count
// to lastSeenAt, the way FUNC(attendanceReport) counts them.
private _totals = createHashMap;
{
    _x params ["_uid", "", "_joined", "_seen", "_left"];
    private _end = [_left, _seen] select (_left isEqualTo "");
    private _mins = (([_end] call FUNC(stampMinutes)) # 0) - (([_joined] call FUNC(stampMinutes)) # 0);
    private _t = _totals getOrDefault [_uid, [0, 0]];
    _t set [0, (_t # 0) + (_mins max 0)];
    _t set [1, (_t # 1) + 1];
    _totals set [_uid, _t];
} forEach GVAR(sessions);

{
    private _rec = _y;
    _out pushBack [
        _x,
        _rec getOrDefault ["name", ""],
        _rec getOrDefault ["rankId", ""],
        _rec getOrDefault ["roleId", ""],
        _rec getOrDefault ["groupId", ""],
        _rec getOrDefault ["statusId", ""],
        _rec getOrDefault ["skillIds", []],
        _rec getOrDefault ["awards", []],
        _rec getOrDefault ["updatedAt", ""],
        _totals getOrDefault [_x, [0, 0]]
    ];
} forEach GVAR(players);

// Sorted by name here rather than on every client's every redraw - the server
// does it once and forty machines do not each do it forty times a minute. The
// rows lead with the UID, which is the key and not the sort, so they are sorted
// through a name-first pair and unwrapped.
private _byName = _out apply { [toLower (_x # 1), _x] };
_byName sort true;
_out = _byName apply { _x # 1 };

GVAR(roster) = _out;
publicVariable QGVAR(roster);

// The live tile's numbers, kept apart from the roster so the tile does not have
// to walk it. Phase 2 wants exactly this shape and calls it a summary struct.
GVAR(summary) = createHashMapFromArray [
    ["hash", GVAR(structureHash)],
    ["orphans", +GVAR(orphans)],
    ["readOnly", GVAR(readOnly)],
    ["savedAt", GVAR(savedAt)],
    ["backend", ["profile", "profile + service (pacdb)"] select GVAR(svcUp)],
    ["ready", GVAR(ready)],
    ["opord", GVAR(settings) getOrDefault ["currentOpord", ""]],
    ["players", count GVAR(players)],
    ["window", [] call FUNC(windowCurrent)],
    ["windowName", [[] call FUNC(windowCurrent)] call FUNC(windowName)]
];
publicVariable QGVAR(summary);
publicVariable QGVAR(opordArchive);

// The host does not hear its own publicVariable - run its handlers by hand.
["roster"] call FUNC(hostRefresh);

TRACE_1("roster published",count _out);

nil
