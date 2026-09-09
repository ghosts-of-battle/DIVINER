#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_svcStructure

Description:
    Reads the unit's config out of the service, ONE DOCUMENT PER CONFIG
    FILE (and one per role, one per order), and assembles the structure
    document FUNC(structureAdopt) takes:

        <unit>.settings          { section: "settings",  items: {...} }
        <unit>.ranks             { section: "ranks",     items: {id: rank} }
        <unit>.skills / .awards / .statuses / .admins / .nets / .templates /
        <unit>.schemes           - the same shape
        <unit>.radio             { section: "radio",     items: {key: value} }
                                 - config_radio.hpp's globals by name
        <unit>.orbat             { section: "orbat", faction, groups,
                                   platoons, radioNets }
        <unit>.role.<class>      { section: "role", id, role: {...} }  - the
                                 whole role, config_roles.hpp's shape plus
                                 PAC's gates; {deleted: true} is skipped
        <unit>.opord.<id>        { section: "opord", id, order: {...} }

    Roles and orders are found by listing the service for the
    "<unit>.role." and "<unit>.opord." prefixes, so a new one is a new
    document and nothing else. A database written before roles had their
    own documents holds one "<unit>.roles" document instead; that is read
    when no role documents exist, and the first edit or push writes the
    new shape. A section document that is missing is an empty section;
    the database "has a config" when at least one document exists. Server
    only, scheduled - every read waits its turn (FUNC(svcLoad)).

Parameters:
    None

Returns:
    [document for structureAdopt, status] - status "ok" (something found),
    "empty" (nothing in the database), "error" <ARRAY>

Author:
    YonV
---------------------------------------------------------------------------- */

if (!isServer) exitWith {[createHashMap, "error"]};

private _unit = GVAR(settings) getOrDefault ["unitId", ""];
private _structure = createHashMap;
private _settings = createHashMap;
private _found = 0;
private _errors = 0;

{
    private _section = _x;
    ([_unit + "." + _section] call FUNC(svcLoad)) params ["_doc", "_status"];
    switch (_status) do {
        case "ok": {
            private _items = _doc getOrDefault ["items", createHashMap];
            if !(_items isEqualType createHashMap) then {_items = createHashMap};
            // The admin document is edited on the database's own site as a plain
            // list of Steam ids ("ids"); anyone in that list is an admin, named
            // or not. The map ("items") carries names the in-game editor set.
            if (_section isEqualTo "admins") then {
                private _ids = _doc getOrDefault ["ids", []];
                if (_ids isEqualType []) then {
                    {
                        private _uid = if (_x isEqualType "") then {_x} else {str _x};
                        if !(_uid in _items) then {_items set [_uid, createHashMapFromArray [["id", _uid], ["name", ""]]]};
                    } forEach _ids;
                };
            };
            if (_section isEqualTo "settings") then {_settings = _items} else {_structure set [_section, _items]};
            _found = _found + 1;
        };
        case "empty": {
            if (_section isNotEqualTo "settings") then {_structure set [_section, createHashMap]};
        };
        default {_errors = _errors + 1};
    };
} forEach ["admins", "settings", "ranks", "skills", "awards", "statuses", "nets", "radio", "templates", "schemes", "promotion", "trainings"];

// the ORBAT document
([_unit + ".orbat"] call FUNC(svcLoad)) params ["_odoc", "_ostatus"];
if (_ostatus isEqualTo "error") exitWith {[createHashMap, "error"]};
if (_ostatus isEqualTo "ok") then {
    private _g = _odoc getOrDefault ["groups", []];
    private _p = _odoc getOrDefault ["platoons", []];
    private _r = _odoc getOrDefault ["radioNets", []];
    private _f = _odoc getOrDefault ["faction", ""];
    if (_g isEqualType [] && _p isEqualType []) then {
        if !(_r isEqualType []) then {_r = []};
        if !(_f isEqualType "") then {_f = ""};
        _structure set ["orbat", createHashMapFromArray [["groups", _g], ["platoons", _p], ["radioNets", _r], ["faction", _f]]];
        _found = _found + 1;
    };
};

if (_errors > 0) exitWith {[createHashMap, "error"]};

// ---- the roles, one document each ------------------------------------------
private _roles = createHashMap;
([_unit + ".role.", "list"] call FUNC(svcLoad)) params ["_rkeys", "_rlstatus"];
if (_rlstatus isEqualTo "error") exitWith {[createHashMap, "error"]};
if (_rkeys isEqualType []) then {
    {
        ([_x] call FUNC(svcLoad)) params ["_doc", "_status"];
        if (_status isEqualTo "ok") then {
            if ((_doc getOrDefault ["deleted", false]) isEqualTo true) then {continue};
            private _role = _doc getOrDefault ["role", createHashMap];
            private _id = _doc getOrDefault ["id", ""];
            if (_id isEqualTo "" && {_role isEqualType createHashMap}) then {_id = _role getOrDefault ["id", ""]};
            if (_role isEqualType createHashMap && _id isNotEqualTo "") then {
                _role set ["id", _id];
                _roles set [_id, _role];
                _found = _found + 1;
            };
        };
    } forEach _rkeys;
};
// the shape before roles had documents of their own: <unit>.roles {items}
if (count _roles isEqualTo 0) then {
    ([_unit + ".roles"] call FUNC(svcLoad)) params ["_doc", "_status"];
    if (_status isEqualTo "ok") then {
        private _items = _doc getOrDefault ["items", createHashMap];
        if (_items isEqualType createHashMap) then {
            _roles = _items;
            _found = _found + 1;
        };
    };
};
_structure set ["roles", _roles];

// ---- the orders, one document each ----------------------------------------
private _opords = createHashMap;
([_unit + ".opord.", "list"] call FUNC(svcLoad)) params ["_keys", "_lstatus"];
if (_lstatus isEqualTo "error") exitWith {[createHashMap, "error"]};
if (_keys isEqualType []) then {
    {
        ([_x] call FUNC(svcLoad)) params ["_doc", "_status"];
        if (_status isEqualTo "ok") then {
            private _order = _doc getOrDefault ["order", createHashMap];
            private _id = _doc getOrDefault ["id", ""];
            if (_id isEqualTo "") then {_id = _order getOrDefault ["id", ""]};
            if (_order isEqualType createHashMap && _id isNotEqualTo "") then {
                _order set ["id", _id];
                _opords set [_id, _order];
                _found = _found + 1;
            };
        };
    } forEach _keys;
};
_structure set ["opords", _opords];

if (_found isEqualTo 0) exitWith {[createHashMap, "empty"]};

[createHashMapFromArray [["structure", _structure], ["settings", _settings]], "ok"]
