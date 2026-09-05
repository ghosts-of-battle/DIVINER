#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_seedFromUnit

Description:
    Fills an EMPTY rank or role on a player's record from what the mission
    already gave them: the Arma rank their role set, and the Dynamic_Roles
    slot they took. Server only; the player's machine sends both on spawn,
    because rank is local to where setRank ran.

    THE ROSTER SHOULD NEVER BE BLANK FOR A MAN WITH A SLOT. It was: a record
    is seeded empty on connect (skills stay empty on purpose - that is the
    handoff's DECIDED), and until an admin opened the panel every row read
    as nothing. The rank column shows the first structure rank that maps to
    the same Arma rank; the role column shows the structure role whose
    slotTag is the slot. An admin's later edit wins, because this only ever
    writes into an empty field.

Parameters:
    0: The unit <OBJECT>
    1: Arma rank, as `rank` returns it <STRING>
    2: Dynamic_Roles class the unit is slotted as, "" for none <STRING>
    3: The group's name (groupId group), "" for none <STRING>

Returns:
    Whether anything was written <BOOL>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]], ["_armaRank", "", [""]], ["_slot", "", [""]], ["_groupName", "", [""]]];

if (!isServer || isNull _unit || GVAR(readOnly)) exitWith {false};

private _uid = [_unit] call FUNC(uid);
if (_uid isEqualTo "") exitWith {false};

private _rec = [_uid, name _unit] call FUNC(record);
if (count _rec isEqualTo 0) exitWith {false};

private _changed = false;

if ((_rec getOrDefault ["rankId", ""]) isEqualTo "" && _armaRank isNotEqualTo "") then {
    private _ranks = GVAR(structure) getOrDefault ["ranks", createHashMap];
    private _ids = keys _ranks;
    _ids sort true;
    private _hit = _ids findIf {toUpper ((_ranks get _x) getOrDefault ["armaRank", ""]) isEqualTo toUpper _armaRank};
    if (_hit >= 0) then {
        _rec set ["rankId", _ids # _hit];
        _changed = true;
    };
};

if ((_rec getOrDefault ["roleId", ""]) isEqualTo "" && _slot isNotEqualTo "") then {
    private _roles = GVAR(structure) getOrDefault ["roles", createHashMap];
    private _ids = keys _roles;
    _ids sort true;
    private _hit = _ids findIf {((_roles get _x) getOrDefault ["slotTag", ""]) isEqualTo _slot};
    if (_hit >= 0) then {
        _rec set ["roleId", _ids # _hit];
        _changed = true;
    };
};

// SKILLS, ONCE, FROM THE ROLE. PAC is the source of truth for skills and the
// roles no longer apply them; the day that switches on, every man would
// arrive with nothing. So the first time a record is seen with a slot, the
// role's traits and customVariables are read and every structure skill whose
// effects the role satisfied is granted. Flagged on the record so an admin
// who later clears a man's skills is not overruled at his next spawn.
if (!(_rec getOrDefault ["skillsSeeded", false]) && _slot isNotEqualTo "") then {
    // The role as the structure holds it - the database's or the mission's,
    // whole (FUNC(rolesFromMission)) - so a unit with no config_roles.hpp
    // seeds exactly as one with.
    private _roleRec = (GVAR(structure) getOrDefault ["roles", createHashMap]) getOrDefault [_slot, createHashMap];
    if !(_roleRec isEqualType createHashMap) then {_roleRec = createHashMap};
    private _has = [];
    {
        if !(_x isEqualType []) then {continue};
        _x params ["_n", ["_v", "false"]];
        // A number (an ACE class) counts when above zero; "true"/"1" as text does.
        if (_v isEqualType 0) then {_v = ["false", "true"] select (_v > 0)};
        if (_v in ["true", "1"]) then {_has pushBackUnique toLower _n};
    } forEach ((_roleRec getOrDefault ["traits", []]) + (_roleRec getOrDefault ["customVariables", []]));

    private _fnc_satisfied = {
        params ["_effect"];
        private _parts = _effect splitString ":";
        if (count _parts < 2) exitWith {false};
        private _val = toLower trim ((_parts select [1]) joinString ":");
        switch (toLower trim (_parts # 0)) do {
            case "medic": {"medic" in _has || "ace_medical_medicclass" in _has};
            case "engineer": {"engineer" in _has || "ace_isengineer" in _has};
            case "eod": {"explosivespecialist" in _has || "ace_iseod" in _has};
            case "trait": {_val in _has};
            case "var": {(trim ((_val splitString "=") # 0)) in _has};
            default {false};
        };
    };

    private _granted = [];
    {
        private _effects = _y getOrDefault ["effects", []];
        if (_effects isNotEqualTo [] && {(_effects findIf {!([_x] call _fnc_satisfied)}) < 0}) then {_granted pushBack _x};
    } forEach (GVAR(structure) getOrDefault ["skills", createHashMap]);
    _granted sort true;

    if ((_rec getOrDefault ["skillIds", []]) isEqualTo []) then {_rec set ["skillIds", _granted]};
    _rec set ["skillsSeeded", true];
    _changed = true;
    INFO_3("%1: skills seeded from role %2: %3",name _unit,_slot,_granted);
};

if ((_rec getOrDefault ["groupId", ""]) isEqualTo "" && _groupName isNotEqualTo "") then {
    _rec set ["groupId", _groupName];
    _changed = true;
};

if (!_changed) exitWith {false};

_rec set ["updatedAt", [] call FUNC(stamp)];
_rec set ["serverId", GVAR(settings) getOrDefault ["serverId", ""]];
GVAR(players) set [_uid, _rec];

private _rankNow = _rec getOrDefault ["rankId", ""];
private _roleNow = _rec getOrDefault ["roleId", ""];
INFO_3("seeded %1 from the unit: rank %2, role %3",name _unit,_rankNow,_roleNow);

[] call FUNC(storeSave);
[] call FUNC(publish);

true
