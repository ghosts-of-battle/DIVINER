#include "script_component.hpp"
/*
    File: fnc_bootDoc.sqf
    Author: YonV
    Description: One line of the boot screen's CHECKLIST - a document (or a
        family of documents) the service read is asking for, and where it
        has got to. Server only; published so every client's boot screen
        ticks the box as it lands (user, 2026-09-10: "this needs to be more
        verbose maybe even with check boxes and a moving progress bar").

        THE BAR MOVES WITH IT. The service read is the long step - fifty
        documents at a second and a half each - and the bar used to sit
        still through the whole of it. GVAR(bootStep) is now step three's
        share filled by how many of the planned documents have landed.

    Parameters:
        0: Label <STRING> - "ranks", "roles", "orders" ...
        1: State <STRING> - "wait" | "run" | "ok" | "empty" | "error" | "skip"
        2: Done <NUMBER> (optional, default 0) - for a family, how many so far
        3: Total <NUMBER> (optional, default 1) - for a family, how many in all
        4: Detail <STRING> (optional) - the key being read, or what came back

    Returns:
        Nothing
*/

params [["_label", "", [""]], ["_state", "wait", [""]], ["_done", 0, [0]], ["_total", 1, [0]], ["_detail", "", [""]]];

if (!isServer || _label isEqualTo "") exitWith {};
if (isNil QGVAR(bootDocs)) then {GVAR(bootDocs) = []};

private _row = [_label, _state, _done, _total max 1, _detail];
private _at = GVAR(bootDocs) findIf {(_x # 0) isEqualTo _label};
if (_at < 0) then {GVAR(bootDocs) pushBack _row} else {GVAR(bootDocs) set [_at, _row]};

// step three's share of the bar: what has landed over what was planned
private _d = 0;
private _t = 0;
{
    _x params ["", "_s", "_dn", "_tt"];
    private _full = _s in ["ok", "empty", "error", "skip"];
    _d = _d + ([_dn, _tt] select _full);
    _t = _t + _tt;
} forEach GVAR(bootDocs);
GVAR(bootStep) = (2 + ((_d / (_t max 1)) min 1)) / 6;

publicVariable QGVAR(bootDocs);
publicVariable QGVAR(bootStep);
