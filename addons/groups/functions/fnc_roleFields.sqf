#include "script_component.hpp"
/*
    File: fnc_roleFields.sqf
    Author: YonV
    Description: The properties a Dynamic_Roles class carries, by config name
        and kind - the mission/mod contract for a role, in one list.
        FUNC(roleFromConfig) reads a class by it, and TAC//PAC's role records
        carry the same names, so a role kept in the unit's database and a
        role written in a mission file are the same record with the same
        keys. Add a property here and every reader of FUNC(role) can see it.

    Parameters:
        None

    Returns:
        ARRAY - [[field, kind], ...], kind "t" text or "a" array
*/

[
    ["name", "t"],
    ["description", "t"],
    ["icon", "t"],
    ["nets", "a"],
    ["tiles", "a"],
    ["traits", "a"],
    ["customVariables", "a"],
    ["defaultLoadout", "a"],
    ["groupArsenal", "t"],
    ["arsenalWeapons", "a"],
    ["arsenalMagazines", "a"],
    ["arsenalItems", "a"],
    ["arsenalBackpacks", "a"]
]
