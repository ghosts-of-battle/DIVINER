#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_backupDump

Description:
    Writes the whole store into the server's .rpt, between marker lines, so a
    profile that is lost or corrupted can be rebuilt from the log. Runs at
    mission end and when an op window is stopped - the handoff's two
    moments - and whenever an admin wants one.

    THE JSON IS SPLIT ACROSS LINES. diag_log cuts a long string, and a real
    store is far past the cut. So the document goes out in slices of
    PAC_LOG_SLICE characters, one per line, and the reader of the log joins
    every line between BEGIN and END back together before parsing. Slices
    are cut on character count, never on structure - a slice boundary can
    fall inside a string and that is fine, because nothing is read until the
    lines are joined.

Parameters:
    0: Reason <STRING> - written into the marker, e.g. "mission end"

Returns:
    How many lines were written <NUMBER>

Author:
    YonV
---------------------------------------------------------------------------- */

#define PAC_LOG_SLICE 2000

params [["_reason", "", [""]]];

if (!isServer) exitWith {0};

private _json = [false] call FUNC(storeJson);
private _total = count _json;
private _lines = 0;

diag_log format ["[TAC//PAC] BACKUP BEGIN %1 - %2 - %3 chars, %4 player(s)", [] call FUNC(stamp), _reason, _total, count GVAR(players)];

private _at = 0;
while {_at < _total} do {
    diag_log format ["[TAC//PAC] %1", _json select [_at, PAC_LOG_SLICE]];
    _at = _at + PAC_LOG_SLICE;
    _lines = _lines + 1;
};

diag_log format ["[TAC//PAC] BACKUP END - %1 line(s)", _lines];

INFO_2("backup written to .rpt (%1) - %2 line(s)",_reason,_lines);

_lines
