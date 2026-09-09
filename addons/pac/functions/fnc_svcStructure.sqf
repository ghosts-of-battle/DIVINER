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
        <unit>.schemes / .traits - the same shape. "traits" is the unit's own
                                 trait catalogue (2026-09-09): the names that
                                 are NOT the engine's seven, so a role editor
                                 can offer them as a list instead of asking
                                 somebody to type one and get the custom flag
                                 right.
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
} forEach ["admins", "settings", "ranks", "skills", "awards", "statuses", "nets", "radio", "templates", "schemes", "promotion", "trainings", "motorpool", "traits"];

// the ORBAT document. A unit may keep more than one - <unit>.orbat.<id> -
// and the "currentOrbat" setting names which this mission wants; empty means
// the common one. Same arrangement as currentOpord picking an order.
private _orbatKey = _unit + ".orbat";
private _wantOrbat = _settings getOrDefault ["currentOrbat", ""];
if (_wantOrbat isEqualType "" && _wantOrbat isNotEqualTo "") then {
    _orbatKey = _unit + ".orbat." + _wantOrbat;
};
([_orbatKey] call FUNC(svcLoad)) params ["_odoc", "_ostatus"];
// A named ORBAT that is not there falls back to the common one rather than
// leaving the mission with no order of battle at all.
if (_ostatus isNotEqualTo "ok" && _orbatKey isNotEqualTo (_unit + ".orbat")) then {
    ([_unit + ".orbat"] call FUNC(svcLoad)) params ["_odoc", "_ostatus"];
};
if (_ostatus isEqualTo "error") exitWith {[createHashMap, "error"]};
if (_ostatus isEqualTo "ok") then {
    private _g = _odoc getOrDefault ["groups", []];
    private _p = _odoc getOrDefault ["platoons", []];
    private _r = _odoc getOrDefault ["radioNets", []];
    private _f = _odoc getOrDefault ["faction", ""];
    private _s = _odoc getOrDefault ["side", ""];
    if (_g isEqualType [] && _p isEqualType []) then {
        if !(_r isEqualType []) then {_r = []};
        if !(_f isEqualType "") then {_f = ""};
        // The side the unit fights on (2026-09-09). Absent means unsaid, and
        // ghostD_groups_fnc_orbat answers WEST for that - what every caller
        // assumed before the field existed.
        if !(_s isEqualType "") then {_s = ""};
        _structure set ["orbat", createHashMapFromArray [["groups", _g], ["platoons", _p], ["radioNets", _r], ["faction", _f], ["side", _s]]];
        _found = _found + 1;
    };
};

// the WELCOME document - {title, subtitle, lines[]}, not {section, items},
// so it is fetched on its own like the ORBAT. Absent is not an error: a unit
// that has not written one keeps whatever the mission's config says.
([_unit + ".welcome"] call FUNC(svcLoad)) params ["_wdoc", "_wstatus"];
if (_wstatus isEqualTo "error") exitWith {[createHashMap, "error"]};
if (_wstatus isEqualTo "ok") then {
    private _lines = _wdoc getOrDefault ["lines", []];
    if (_lines isEqualType [] && {count _lines > 0}) then {
        _structure set ["welcome", createHashMapFromArray [
            ["title", [_wdoc getOrDefault ["title", ""], ""] select !((_wdoc getOrDefault ["title", ""]) isEqualType "")],
            ["subtitle", [_wdoc getOrDefault ["subtitle", ""], ""] select !((_wdoc getOrDefault ["subtitle", ""]) isEqualType "")],
            ["lines", _lines]
        ]];
        _found = _found + 1;
    };
};

// ---- the list-shaped config documents, and their variants ----------------
// <unit>.arsenal is the common one; <unit>.arsenal.<name> is a variant, found
// by listing the prefix exactly as roles and orders are. A role's
// groupArsenal property names the variant it wants, so the variant id IS the
// class name the mission used - "Arsenal_Banshee" stays "Arsenal_Banshee".
{
    private _doc = _x;
    private _rec = createHashMap;

    ([_unit + "." + _doc] call FUNC(svcLoad)) params ["_ldoc", "_lstatus"];
    if (_lstatus isEqualTo "error") exitWith {};
    if (_lstatus isEqualTo "ok") then {
        private _l = _ldoc getOrDefault ["lists", createHashMap];
        if (_l isEqualType createHashMap) then {_rec set ["lists", _l]};
    };

    private _variants = createHashMap;
    ([_unit + "." + _doc + ".", "list"] call FUNC(svcLoad)) params ["_vkeys", "_vstatus"];
    if (_vstatus isNotEqualTo "error" && {_vkeys isEqualType []}) then {
        {
            ([_x] call FUNC(svcLoad)) params ["_vdoc", "_vst"];
            if (_vst isEqualTo "ok") then {
                private _vl = _vdoc getOrDefault ["lists", createHashMap];
                private _vid = _vdoc getOrDefault ["id", ""];
                if (_vid isEqualTo "") then {
                    _vid = _x select [count (_unit + "." + _doc + "."), 99];
                };
                if (_vl isEqualType createHashMap && _vid isNotEqualTo "") then {
                    _variants set [_vid, _vl];
                };
            };
        } forEach _vkeys;
    };
    if (count _variants > 0) then {_rec set ["variants", _variants]};

    // WHICH VERSION IS THE COMMON ONE (2026-09-09). The unit keeps more than
    // one common arsenal - a bare-bones "Framework" and a set named for the
    // camo an operation is in, Ghost_OCP, Ghost_MTP, Ghost_Tropical ... - and
    // until now nothing could pick between them: the variants were only ever
    // reached by a role's groupArsenal, so the camo sets were documents nobody
    // read. The "currentArsenal" setting names one, exactly as "currentOrbat"
    // names an ORBAT and "currentOpord" an order.
    //
    // IT REPLACES THE COMMON LISTS, it does not add to them - the point of a
    // camo set is that a man cannot draw the other four. Unset, or naming a
    // version that is not there, leaves the common document alone, which is
    // what every mission did before this existed.
    if (_doc isEqualTo "arsenal") then {
        private _want = _settings getOrDefault ["currentArsenal", ""];
        if (_want isEqualType "" && _want isNotEqualTo "") then {
            private _hit = "";
            {
                if (toLower _x isEqualTo toLower _want) exitWith {_hit = _x};
            } forEach (keys _variants);
            if (_hit isEqualTo "") then {
                WARNING_1("currentArsenal names '%1' and there is no such arsenal version - the common one is used",_want);
            } else {
                _rec set ["lists", _variants get _hit];
                INFO_1("common arsenal: the '%1' version",_hit);
            };
        };
    };

    if (count _rec > 0) then {
        _structure set [_doc, _rec];
        _found = _found + 1;
    };
} forEach ["arsenal", "radar"];

// ---- the motorpool's variants (2026-09-09) -------------------------------
// The motorpool is items-shaped, so the loop above - which reads "lists"
// documents - never saw its variants and a platoon's own pool was fetched by
// nobody. <unit>.motorpool.<name> is one pool, and the variant id IS the class
// name the mission used ("MotorPool_Nomad"), the same rule as the arsenal.
private _mpVariants = createHashMap;
([_unit + ".motorpool.", "list"] call FUNC(svcLoad)) params ["_mpKeys", "_mpStatus"];
if (_mpStatus isNotEqualTo "error" && _mpKeys isEqualType []) then {
    {
        ([_x] call FUNC(svcLoad)) params ["_vdoc", "_vst"];
        if (_vst isEqualTo "ok") then {
            private _vitems = _vdoc getOrDefault ["items", createHashMap];
            private _vid = _vdoc getOrDefault ["id", ""];
            if (_vid isEqualTo "") then {
                _vid = _x select [count (_unit + ".motorpool."), 99];
            };
            if (_vitems isEqualType createHashMap && _vid isNotEqualTo "") then {
                _mpVariants set [_vid, _vitems];
            };
        };
    } forEach _mpKeys;
};
if (count _mpVariants > 0) then {
    _structure set ["motorpoolVariants", _mpVariants];
    _found = _found + 1;
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
