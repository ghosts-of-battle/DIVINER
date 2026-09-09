#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_cfgLists

Description:
    The named lists of a config document the unit keeps in the database -
    <unit>.arsenal, <unit>.radar - as {name: [values]}.

    THE DATABASE ADDS TO THE MISSION, IT DOES NOT REPLACE IT. Every caller
    still reads its own mission class first and then appends what this returns.
    That ordering is deliberate: a mission that ships a config folder keeps
    working untouched, a mission that ships none gets everything from here, and
    a unit part-way through the move gets both. Nothing has to be migrated in
    one go.

    EMPTY IS THE NORMAL ANSWER on a server whose unit has written no template
    yet, so callers must treat an empty hashmap as "nothing to add" and never
    as an error.

Parameters:
    0: Document <STRING> - "arsenal", "radar"

Returns:
    {listName: [values]} <HASHMAP>, empty when there is nothing

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_doc", "", [""]]];

if (_doc isEqualTo "") exitWith {createHashMap};

private _sec = GVAR(structure) getOrDefault [_doc, createHashMap];
if !(_sec isEqualType createHashMap) exitWith {createHashMap};

private _lists = _sec getOrDefault ["lists", createHashMap];
if !(_lists isEqualType createHashMap) exitWith {createHashMap};

_lists
