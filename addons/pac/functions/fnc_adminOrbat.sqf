#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_adminOrbat

Description:
    The one door through which the ORBAT is edited in game - the squads
    and their slots, the platoon tabs, the shared radio nets and the
    faction's name - by an admin, on the server, checked the way
    FUNC(adminSet) checks. The ORBAT is the structure's "orbat" section
    (the <unit>.orbat document with the service); after the edit the live
    slot table is rebuilt from it (ghostD_groups_fnc_orbatApply - nobody
    seated is thrown out), it is persisted (FUNC(structurePersist)), logged
    and sent to every client.

        squad     key = the squad's name as it is now ("" for a new one);
                  record {name, roles (array of role classes, or a comma
                  string), condition, position (1-based; 0 = leave)}.
                  Role classes must be roles the structure has. ORDER IS
                  THE SR RADIO CHANNEL ORDER, so position is a real edit.
        platoon   key = the tab id; record {name, callsign, net, squads}
        radioNet  key = the net id; record {net, squads}
        faction   record {name}

Parameters:
    0: Caller <OBJECT>
    1: Kind <STRING> - "squad" | "platoon" | "radioNet" | "faction"
    2: Op <STRING> - "set" | "remove"
    3: Key <STRING>
    4: Record <HASHMAP> (set only)

Returns:
    Whether the change was made <BOOL>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_caller", objNull, [objNull]], ["_kind", "", [""]], ["_op", "", [""]], ["_key", "", [""]], ["_rec", createHashMap, [createHashMap]]];

if (!isServer) exitWith {false};
if (isNull _caller || {!([_caller] call ghostD_adminpanel_fnc_isAdmin)}) exitWith {
    WARNING_2("adminOrbat refused: %1 is not an admin (%2)",name _caller,_kind);
    false
};
if (GVAR(readOnly)) exitWith {false};

private _fnc_tell = {
    params ["_msg", "_bad"];
    ["TAC//PAC", _msg, [[0.4, 0.702, 0.4, 1], [0.831, 0.267, 0.267, 1]] select _bad] remoteExec ["ghostD_notify_fnc_notify", owner _caller];
};

private _fnc_text = {
    params ["_field"];
    private _v = _rec getOrDefault [_field, ""];
    if !(_v isEqualType "") then {_v = str _v};
    trim _v
};
private _fnc_list = {
    params ["_field"];
    private _v = _rec getOrDefault [_field, []];
    if (_v isEqualType "") then {_v = (_v splitString ",") apply {trim _x}};
    if !(_v isEqualType []) then {_v = []};
    (_v select {_x isEqualType "" && _x isNotEqualTo ""})
};

// the ORBAT as it is, copied - the edit is made whole or not at all
private _orbat = +(GVAR(structure) getOrDefault ["orbat", createHashMap]);
if !(_orbat isEqualType createHashMap) then {_orbat = createHashMap};
private _groups = _orbat getOrDefault ["groups", []];
private _platoons = _orbat getOrDefault ["platoons", []];
private _radioNets = _orbat getOrDefault ["radioNets", []];
private _detail = "";
private _ok = true;

switch (_kind) do {
    case "faction": {
        private _name = ["name"] call _fnc_text;
        _orbat set ["faction", _name];
        _detail = format ["faction '%1'", _name];
    };
    case "squad": {
        private _at = _groups findIf {toUpper (_x # 0) isEqualTo toUpper _key};
        if (_op isEqualTo "remove") exitWith {
            if (_at < 0) exitWith {[format ["No squad '%1'.", _key], true] call _fnc_tell; _ok = false};
            _groups deleteAt _at;
            _detail = format ["squad '%1' removed", _key];
        };
        private _name = ["name"] call _fnc_text;
        if (_name isEqualTo "") exitWith {["A squad needs a name.", true] call _fnc_tell; _ok = false};
        private _roles = ["roles"] call _fnc_list;
        if (_roles isEqualTo []) exitWith {["A squad needs at least one slot - a role class per slot, comma-separated.", true] call _fnc_tell; _ok = false};
        private _known = GVAR(structure) getOrDefault ["roles", createHashMap];
        private _bad = _roles select {!(_x in _known)};
        if (_bad isNotEqualTo []) exitWith {[format ["Not roles the structure has: %1", _bad joinString ", "], true] call _fnc_tell; _ok = false};
        private _cond = ["condition"] call _fnc_text;
        if (_cond isEqualTo "") then {_cond = "true"};
        private _dupe = _groups findIf {toUpper (_x # 0) isEqualTo toUpper _name};
        if (_dupe >= 0 && _dupe isNotEqualTo _at) exitWith {[format ["There is already a squad called '%1'.", _name], true] call _fnc_tell; _ok = false};
        private _row = [_name, _roles, _cond];
        if (_at >= 0) then {_groups set [_at, _row]} else {_groups pushBack _row; _at = (count _groups) - 1};
        private _pos = _rec getOrDefault ["position", 0];
        if (_pos isEqualType "") then {_pos = parseNumber _pos};
        if !(_pos isEqualType 0) then {_pos = 0};
        if (_pos >= 1 && _pos <= count _groups && (_pos - 1) isNotEqualTo _at) then {
            _groups deleteAt _at;
            _groups = (_groups select [0, _pos - 1]) + [_row] + (_groups select [_pos - 1]);
        };
        _detail = format ["squad '%1': %2 slot(s) [%3], condition %4, position %5", _name, count _roles, _roles joinString " ", _cond, (_groups findIf {(_x # 0) isEqualTo _name}) + 1];
    };
    case "platoon": {
        private _at = _platoons findIf {(_x # 0) isEqualTo _key};
        if (_op isEqualTo "remove") exitWith {
            if (_at < 0) exitWith {[format ["No platoon tab '%1'.", _key], true] call _fnc_tell; _ok = false};
            _platoons deleteAt _at;
            _detail = format ["platoon tab '%1' removed", _key];
        };
        private _id = ["id"] call _fnc_text;
        if (_id isEqualTo "") then {_id = _key};
        if (_id isEqualTo "") exitWith {["A platoon tab needs an id.", true] call _fnc_tell; _ok = false};
        private _row = [_id, ["name"] call _fnc_text, ["callsign"] call _fnc_text, ["net"] call _fnc_text, ["squads"] call _fnc_list];
        if (_at >= 0) then {_platoons set [_at, _row]} else {_platoons pushBack _row};
        _detail = format ["platoon tab '%1': %2 / %3, net %4, squads [%5]", _id, _row # 1, _row # 2, _row # 3, (_row # 4) joinString ", "];
    };
    case "radioNet": {
        private _at = _radioNets findIf {(_x # 0) isEqualTo _key};
        if (_op isEqualTo "remove") exitWith {
            if (_at < 0) exitWith {[format ["No radio net '%1'.", _key], true] call _fnc_tell; _ok = false};
            _radioNets deleteAt _at;
            _detail = format ["radio net '%1' removed", _key];
        };
        private _id = ["id"] call _fnc_text;
        if (_id isEqualTo "") then {_id = _key};
        if (_id isEqualTo "") exitWith {["A radio net needs an id.", true] call _fnc_tell; _ok = false};
        private _row = [_id, ["net"] call _fnc_text, ["squads"] call _fnc_list];
        if (_at >= 0) then {_radioNets set [_at, _row]} else {_radioNets pushBack _row};
        _detail = format ["radio net '%1': %2, squads [%3]", _id, _row # 1, (_row # 2) joinString ", "];
    };
    default {
        _ok = false;
    };
};
if (!_ok) exitWith {false};

_orbat set ["groups", _groups];
_orbat set ["platoons", _platoons];
_orbat set ["radioNets", _radioNets];
GVAR(structure) set ["orbat", _orbat];

// the live slot table, the platoon tags, the persistence, the log
if (!isNil "ghostD_groups_fnc_orbatApply") then {[] call ghostD_groups_fnc_orbatApply};
missionNamespace setVariable ["ghostD_messaging_platoonTagCache", nil];
[getPlayerUID _caller, name _caller, "orbat", "", _detail] call FUNC(logAction);
["orbat"] call FUNC(structurePersist);

INFO_2("%1 edited the ORBAT: %2",name _caller,_detail);
[format ["ORBAT: %1.", _detail], false] call _fnc_tell;
true
