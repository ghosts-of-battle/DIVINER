#include "script_component.hpp"
/*
    File: fnc_roleFromConfig.sqf
    Author: YonV
    Description: One Dynamic_Roles class as a record - the shape FUNC(role)
        answers and TAC//PAC stores. Every property in FUNC(roleFields), by
        its config name, plus "id" = the class. A class the mission does
        not have is an empty record, so a reader can getOrDefault its way
        through a role that lives nowhere.

    Parameters:
        0: STRING - the role class

    Returns:
        HASHMAP - the record, empty when there is no such class
*/

params [["_class", "", [""]]];

private _cfg = missionConfigFile >> "Dynamic_Roles" >> _class;
if (_class isEqualTo "" || {!isClass _cfg}) exitWith {createHashMap};

private _rec = createHashMapFromArray [["id", _class]];
{
    _x params ["_field", "_kind"];
    private _c = _cfg >> _field;
    _rec set [_field, if (_kind isEqualTo "a") then {getArray _c} else {getText _c}];
} forEach ([] call FUNC(roleFields));

_rec
