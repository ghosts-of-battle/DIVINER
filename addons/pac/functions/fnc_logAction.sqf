#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_logAction

Description:
    THE ACTION LOG. One line per thing an admin did, dated, kept in the
    store (GVAR(log), the profile key gfa_pac_log, the store document) and
    - when the action was done TO a player - on that player's record as
    well, under adminActions, so their record reads as a file and the log
    reads as a ledger. Server only; every server-side door (adminSet,
    adminStructure, adminOrbat, windowSet, import, seedSample, the
    kick/ban relay) calls it after it has done the thing.

        log row        [LOG-n, date, byUid, byName, type, targetUid,
                        targetName, detail]
        adminActions   [LOG-n, type, date, byUid, byName, detail]

    The id is a counter in the store's meta, so a line can be quoted. The
    log is capped at PAC_LOG_MAX rows, oldest dropped; a record's own
    actions are never dropped.

Parameters:
    0: Who did it - Steam id <STRING>
    1: Their name <STRING>
    2: Type <STRING> - rank, role, group, status, skills, award, note,
       operator, excuse, structure, orbat, window, import, sample, kick, ban
    3: Target uid <STRING> - "" when the action was not on a player
    4: Detail <STRING> - what changed, in words

Returns:
    The log id <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_byUid", "", [""]], ["_byName", "", [""]], ["_type", "", [""]], ["_targetUid", "", [""]], ["_detail", "", [""]]];

if (!isServer || _type isEqualTo "") exitWith {""};

private _now = [] call FUNC(stamp);
private _seq = (GVAR(meta) getOrDefault ["logSeq", 0]) + 1;
GVAR(meta) set ["logSeq", _seq];
private _id = "LOG-" + str _seq;

private _targetName = "";
if (_targetUid isNotEqualTo "") then {
    private _rec = GVAR(players) getOrDefault [_targetUid, createHashMap];
    if (count _rec > 0) then {
        _targetName = _rec getOrDefault ["name", ""];
        private _actions = _rec getOrDefault ["adminActions", []];
        _actions pushBack [_id, _type, _now, _byUid, _byName, _detail];
        _rec set ["adminActions", _actions];
    };
};

GVAR(log) pushBack [_id, _now, _byUid, _byName, _type, _targetUid, _targetName, _detail];
if (count GVAR(log) > PAC_LOG_MAX) then {
    GVAR(log) deleteRange [0, (count GVAR(log)) - PAC_LOG_MAX];
};

private _line = format ["%1 %2 %3 by %4%5: %6", _id, _now, _type, _byName, ["", " on " + _targetName] select (_targetName isNotEqualTo ""), _detail];
INFO_1("log: %1",_line);

_id
