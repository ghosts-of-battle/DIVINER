#include "script_component.hpp"
/*
    File: fnc_role.sqf
    Author: YonV
    Description: ONE role, as a record, from ONE place. Every reader of a
        Dynamic_Roles class in the mod - the role tree, the role card, the
        slot setup, the net and tile gates, the slot gate - asks this
        instead of missionConfigFile, so a unit that keeps its roles in
        TAC//PAC's database (or the profile) sees them everywhere at once.

        WHERE IT LOOKS. TAC//PAC's structure first: its "roles" section is
        the database's roles when the unit keeps them there, and the
        mission's own classes compiled into the same shape otherwise
        (ghostD_pac_fnc_rolesFromMission), so on a mission that still ships
        config_roles.hpp the answer is the same either way. Without the pac
        addon, or before its structure has arrived on this machine, the
        class is read from the mission and cached - a config walk per row
        per redraw is what the cache is for.

        The keys are FUNC(roleFields)'s names, plus whatever TAC//PAC adds
        (minRank, requiredSkills, uids, slotTag ...). Read with getOrDefault:
        a role that lives only in the database may lack a field the mission
        contract has, and a role that lives only in a file lacks PAC's.

    Parameters:
        0: STRING - the role class

    Returns:
        HASHMAP - the record, empty for a class nobody knows
*/

params [["_class", "", [""]]];

if (_class isEqualTo "") exitWith {createHashMap};

private _pac = (missionNamespace getVariable ["ghostD_pac_structure", createHashMap]) getOrDefault ["roles", createHashMap];
private _rec = createHashMap;
if (_pac isEqualType createHashMap) then {_rec = _pac getOrDefault [_class, createHashMap]};
if (_rec isEqualType createHashMap && {count _rec > 0}) exitWith {_rec};

// the mission's, compiled once per class per machine
if (isNil QGVAR(roleCache)) then {GVAR(roleCache) = createHashMap};
GVAR(roleCache) getOrDefaultCall [_class, {[_class] call FUNC(roleFromConfig)}, true]
