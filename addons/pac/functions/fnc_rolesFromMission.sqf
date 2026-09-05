#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_rolesFromMission

Description:
    Merges every Dynamic_Roles class into structure.roles - the WHOLE role,
    every property the group system reads (ghostD_groups_fnc_roleFields:
    name, description, icon, nets, tiles, traits, customVariables,
    defaultLoadout, groupArsenal, the four arsenal arrays) plus PAC's own
    (minRank, requiredSkills, uids, arsenalWhitelist, defaultSkills,
    slotTag) - so a role in the database and a role in a mission file are
    the same record, and the group menu reads either through
    ghostD_groups_fnc_role.

    STORAGE WINS, THE MISSION IS THE SEED. A role the structure already
    holds keeps every field it has; only fields it LACKS are filled from
    the class (an older gate-only record gets its loadout and nets this
    way), and an empty name or slotTag is filled too, because neither is
    ever empty on purpose. A class the structure has never seen becomes a
    full record. A role in the structure that no class declares stays as
    it is - it is the database's, and a mission without config_roles.hpp
    has nothing but those.

    Called by FUNC(loadStructure) after the config read, by
    FUNC(structureAdopt) after a service document, by FUNC(boot) after the
    profile overlay and by FUNC(adminStructure) after a roles edit, so
    every path agrees. Any machine.

Parameters:
    None

Returns:
    How many roles the structure has now <NUMBER>

Author:
    YonV
---------------------------------------------------------------------------- */

private _roles = GVAR(structure) getOrDefault ["roles", createHashMap];
if !(_roles isEqualType createHashMap) then {_roles = createHashMap};

private _fields = [["name", "t"]] + ((["roles"] call FUNC(structFields)) apply {[_x # 0, _x # 1]});

{
    private _cfg = _x;
    private _id = configName _cfg;
    private _rec = _roles getOrDefault [_id, createHashMap];
    if !(_rec isEqualType createHashMap) then {_rec = createHashMap};
    _rec set ["id", _id];
    {
        _x params ["_field", "_kind"];
        private _empty = !(_field in _rec) || {_kind isEqualTo "t" && {_field in ["name", "slotTag"]} && {(_rec get _field) isEqualTo ""}};
        if (!_empty) then {continue};
        private _c = _cfg >> _field;
        _rec set [_field, switch (true) do {
            case (_field isEqualTo "slotTag"): {_id};
            case (_kind isEqualTo "a"): {getArray _c};
            default {getText _c};
        }];
    } forEach _fields;
    _roles set [_id, _rec];
} forEach ("true" configClasses (missionConfigFile >> "Dynamic_Roles"));

// every role has every field, whether a class declared it or not
{
    private _id = _x;
    private _rec = _y;
    if !(_rec isEqualType createHashMap) then {continue};
    {
        _x params ["_field", "_kind"];
        if (_field in _rec) then {continue};
        _rec set [_field, switch (true) do {
            case (_field isEqualTo "slotTag"): {_id};
            case (_kind isEqualTo "a"): {[]};
            default {""};
        }];
    } forEach _fields;
    if ((_rec getOrDefault ["slotTag", ""]) isEqualTo "") then {_rec set ["slotTag", _id]};
    if ((_rec getOrDefault ["name", ""]) isEqualTo "") then {_rec set ["name", _id]};
} forEach _roles;

GVAR(structure) set ["roles", _roles];

count _roles
