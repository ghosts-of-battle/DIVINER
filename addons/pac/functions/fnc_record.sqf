#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_record

Description:
    One player's record, seeded if this is the first time the unit has seen them.

    KEYED ON UID, NEVER ON NAME. A name is a display string somebody changes on
    a whim; the UID is the person. The name IS stored, because a roster of UIDs
    is unreadable, but nothing is ever looked up by it.

    SEEDING IS EMPTY, ON PURPOSE. A new player arrives with no rank, no role and
    no skills, and with `PAC` that means they spawn with no
    skills at all until an admin assigns them - the handoff marks that DECIDED.
    The alternative is a system that quietly grants things, and a unit that
    tracks qualifications cannot have one of those. Two things are written
    at once because they are facts, not grants: an operator id
    (FUNC(operatorSeq)) and the enlistment date - today.

    IT IS THE ONLY PLACE A RECORD IS CREATED, so the shape is defined once -
    FUNC(recordFields). Every key is present from the start rather than
    appearing when something first writes it: a record whose keys depend on
    what has happened to the player is a record every reader has to guard
    against.

Parameters:
    0: UID <STRING>
    1: Name to seed or refresh with <STRING> (optional, default "")

Returns:
    The record <HASHMAP>, or an empty one off the server

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_uid", "", [""]], ["_name", "", [""]]];

if (!isServer || _uid isEqualTo "") exitWith {createHashMap};

private _rec = GVAR(players) getOrDefault [_uid, createHashMap];

if (count _rec isEqualTo 0) then {
    private _now = [] call FUNC(stamp);
    _rec = createHashMap;
    {
        _x params ["_key", "_empty"];
        _rec set [_key, if (_empty isEqualType [] || {_empty isEqualType createHashMap}) then {+_empty} else {_empty}];
    } forEach ([] call FUNC(recordFields));
    _rec set ["name", _name];
    _rec set ["operatorId", [] call FUNC(operatorSeq)];
    _rec set ["enlistedAt", _now select [0, 10]];
    _rec set ["updatedAt", _now];
    _rec set ["serverId", GVAR(settings) getOrDefault ["serverId", ""]];

    GVAR(players) set [_uid, _rec];
    [] call FUNC(storeSave);

    private _op = _rec get "operatorId";
    INFO_3("seeded %1 (%2) as %3",_name,_uid,_op);
};

// THE NAME IS REFRESHED, AND NOTHING ELSE IS. Somebody who renamed themselves
// should read correctly on the roster tomorrow, but a connect is not an edit -
// updatedAt is not touched, because a merge between two servers must not be won
// by whichever one the player happened to log into last.
if (_name isNotEqualTo "" && {(_rec getOrDefault ["name", ""]) isNotEqualTo _name}) then {
    _rec set ["name", _name];
    [] call FUNC(storeSave);
};

_rec
