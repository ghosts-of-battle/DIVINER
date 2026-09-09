#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_adminStructure

Description:
    The one door through which the STRUCTURE is edited in-game - ranks,
    skills, awards, statuses, nets, roles and the admin list - by an admin, on the
    server, checked the way FUNC(adminSet) checks. The mission's config was
    the only source before; a unit that keeps its config in the database
    needs to change a rank without a mission update, and needs it to stick.

    ONE ITEM AT A TIME. "set" writes a whole record under an id (new or
    existing) and "remove" deletes one; ids are the class-name rule - lower
    case, letters, digits, underscore - because they are what every player
    record points at. A removed id becomes an orphan on the records that
    hold it, flagged, never dropped, like a config rename.

    IT STICKS EVERYWHERE THE STORE DOES. After the change the section is
    persisted (FUNC(structurePersist)) - to the service as the section's own
    document when the database is the source, and always to the local
    copies - the hash is recomputed, and the structure goes back out to
    every client.

    ADMINS ARE A SECTION. <unit>.admins holds {uid: {name, addedBy,
    addedAt}}; the console's isAdmin reads it beside the mission's list. An
    admin cannot remove themself - the last way in must not be closable
    from inside.

Parameters:
    0: Caller <OBJECT>
    1: Section <STRING> - "ranks" | "skills" | "awards" | "statuses" | "admins" | "roles" | "nets" | "promotion" | "trainings"
    2: Op <STRING> - "set" | "remove"
    3: Id <STRING>
    4: Record <HASHMAP> (set only) - the section's fields

Returns:
    Whether the change was made <BOOL>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_caller", objNull, [objNull]], ["_section", "", [""]], ["_op", "", [""]], ["_id", "", [""]], ["_rec", createHashMap, [createHashMap]]];

if (!isServer) exitWith {false};
if (isNull _caller || {!([_caller] call ghostD_adminpanel_fnc_isAdmin)}) exitWith {
    WARNING_2("adminStructure refused: %1 is not an admin (%2)",name _caller,_section);
    false
};
if !(_section in ["ranks", "skills", "awards", "statuses", "admins", "roles", "nets", "promotion", "trainings"]) exitWith {false};

private _fnc_tell = {
    params ["_msg", "_bad"];
    ["TAC//PAC", _msg, [[0.4, 0.702, 0.4, 1], [0.831, 0.267, 0.267, 1]] select _bad] remoteExec ["ghostD_notify_fnc_notify", owner _caller];
};

// An id is a class name: [a-z0-9_], not empty. A ROLE's id is its
// Dynamic_Roles class and keeps its case (teamleadBanshee); an admin's is a
// Steam id.
private _upperOk = _section isEqualTo "roles";
private _idOk = _id isNotEqualTo "" && {(toArray _id) findIf {!(_x in [95] || {_x >= 48 && _x <= 57} || {_x >= 97 && _x <= 122} || {_upperOk && {_x >= 65 && _x <= 90}})} < 0};
if (_section isEqualTo "admins") then {_idOk = _id isNotEqualTo "" && {(toArray _id) findIf {!(_x >= 48 && _x <= 57)} < 0}};
// A NET's id is its name on the rail and the radio plan - "C2.reports",
// "GROUND 1", "FIRES.cas" - so letters of either case, digits, dot, space,
// hyphen and underscore.
if (_section isEqualTo "nets") then {_idOk = _id isNotEqualTo "" && {(toArray _id) findIf {!(_x in [95, 46, 32, 45] || {_x >= 48 && _x <= 57} || {_x >= 97 && _x <= 122} || {_x >= 65 && _x <= 90})} < 0}};
if (!_idOk) exitWith {[format ["'%1' is not a valid id (letters, digits, underscore; a Steam id for admins).", _id], true] call _fnc_tell; false};

private _items = GVAR(structure) getOrDefault [_section, createHashMap];
private _fields = [["name", "t"]] + (([_section] call FUNC(structFields)) apply {[_x # 0, _x # 1]});
private _ok = true;

switch (_op) do {
    case "set": {
        // MERGE OVER WHAT IS THERE. The editor sends the fields it shows; a
        // role's default loadout and slotTag are not among them and must not
        // be wiped by a save that only changed its rank gate.
        private _clean = +(_items getOrDefault [_id, createHashMap]);
        _clean set ["id", _id];
        {
            _x params ["_field", "_kind"];
            if !(_field in _rec) then {
                if !(_field in _clean) then {_clean set [_field, switch (_kind) do {case "a": {[]}; case "n": {0}; default {""}}]};
                continue;
            };
            private _v = _rec get _field;
            switch (_kind) do {
                case "a": {
                    if (_v isEqualType "") then {_v = ((_v splitString ",") apply {trim _x}) select {_x isNotEqualTo ""}};
                    if !(_v isEqualType []) then {_v = []};
                };
                case "n": {
                    if (_v isEqualType "") then {_v = parseNumber _v};
                    if !(_v isEqualType 0) then {_v = 0};
                };
                default {
                    if !(_v isEqualType "") then {_v = str _v};
                };
            };
            _clean set [_field, _v];
        } forEach _fields;
        if (_section isEqualTo "ranks" && {!((toUpper (_clean get "armaRank")) in ARMA_RANKS)}) exitWith {
            ["armaRank must be one of PRIVATE CORPORAL SERGEANT LIEUTENANT CAPTAIN MAJOR COLONEL.", true] call _fnc_tell;
        };
        if (_section isEqualTo "roles") then {
            private _mr = _clean getOrDefault ["minRank", ""];
            private _bad = (_clean getOrDefault ["requiredSkills", []]) select {!(_x in (GVAR(structure) getOrDefault ["skills", createHashMap]))};
            if (_mr isNotEqualTo "" && {!(_mr in (GVAR(structure) getOrDefault ["ranks", createHashMap]))}) then {
                [format ["MIN RANK '%1' is not a rank id in the structure.", _mr], true] call _fnc_tell;
                _ok = false;
            };
            if (_bad isNotEqualTo []) then {
                [format ["REQUIRED SKILLS %1 are not skill ids in the structure.", _bad], true] call _fnc_tell;
                _ok = false;
            };
            if ((_clean getOrDefault ["name", ""]) isEqualTo "") then {
                private _fromMission = if (!isNil "ghostD_groups_fnc_roleFromConfig") then {([_id] call ghostD_groups_fnc_roleFromConfig) getOrDefault ["name", ""]} else {""};
                _clean set ["name", [_fromMission, _id] select (_fromMission isEqualTo "")];
            };
            if ((_clean getOrDefault ["slotTag", ""]) isEqualTo "") then {_clean set ["slotTag", _id]};
        };
        if (!_ok) exitWith {};
        if (_section isEqualTo "admins") then {
            _clean set ["addedBy", name _caller];
            _clean set ["addedAt", [] call FUNC(stamp)];
        };
        _items set [_id, _clean];
    };
    case "remove": {
        if (_section isEqualTo "admins" && {_id isEqualTo getPlayerUID _caller}) exitWith {["You cannot remove yourself from the admin list.", true] call _fnc_tell};
        if !(_id in _items) exitWith {[format ["No '%1' in %2.", _id, _section], true] call _fnc_tell};
        _items deleteAt _id;
    };
    default {};
};
if (!_ok) exitWith {false};
GVAR(structure) set [_section, _items];
// A role removed in the editor is a mission role back at the mission's own
// (when the mission still declares it), not a hole in the slot table; a role
// the mission never declared is simply gone. The rest of every role - nets,
// loadout, tiles - rides along untouched under the three gate fields.
if (_section isEqualTo "roles") then {[] call FUNC(rolesFromMission)};

[getPlayerUID _caller, name _caller, "structure", "", format ["%1 %2 '%3'", ["set", "removed"] select (_op isEqualTo "remove"), _section, _id]] call FUNC(logAction);
[_section, _id] call FUNC(structurePersist);

INFO_4("%1 %2 %3 '%4' in the structure",name _caller,_op,_section,_id);
[format ["%1: %2 '%3'.", _section, ["set", "removed"] select (_op isEqualTo "remove"), _id], false] call _fnc_tell;
true
