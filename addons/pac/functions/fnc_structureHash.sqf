#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_structureHash

Description:
    One number for the whole compiled structure.

    WHAT IT IS FOR. Two servers are meant to be kept identical by copying files
    or sharing a database. This is how anybody tells whether they are: the
    live tile shows it, the delta tool prints it, and two tiles reading the
    same number is the answer to "are we in step". A hash that changed when
    nothing had changed would make that check worthless, so it is computed
    off the CONTENT and never off anything incidental.

    ORDER IS FORCED. `keys` on a hashmap has no promised order, and a hash that
    depended on it would differ between two servers running byte-identical
    files. Every hashmap, at every level, is walked with its keys sorted.

    EVERY SHAPE IS WALKED THE SAME WAY. A section is usually {id -> record},
    but the ORBAT is {groups, platoons, ...} of arrays and the radio plan is
    {key -> value} of anything, so the walk is generic: a hashmap by sorted
    key, an array in order, a scalar as text. It used to assume records and
    would have thrown `keys` at an array the first time it met the ORBAT.

    SETTINGS ARE NOT IN IT. serverId differs by design on every box, so
    including settings would guarantee two servers never matched. The hash
    answers "is our structure the same", and a server id is not structure.

    IT IS A CHECKSUM, NOT A SIGNATURE. Cheap, order-stable and good enough to
    notice a rank renamed or an OPORD added. Nothing security-shaped depends on
    it and nothing should.

Parameters:
    None

Returns:
    Hash <NUMBER>

Author:
    YonV
---------------------------------------------------------------------------- */

private _hash = 5381;

// djb2 over a string, kept inside the range SQF holds exactly - a hash that
// drifts into floating point stops being reproducible, which is the one thing
// this has to be.
private _fnc_fold = {
    { _hash = ((_hash * 33) + _x) mod 1000000007 } forEach (toArray (_this select 0));
};

private _fnc_value = {
    params ["_v"];

    if (isNil "_v") exitWith {["~"] call _fnc_fold};

    if (_v isEqualType createHashMap) exitWith {
        private _k = +(keys _v);
        _k sort true;
        {
            [str _x] call _fnc_fold;
            [_v get _x] call _fnc_value;
        } forEach _k;
    };

    if (_v isEqualType []) exitWith {
        { [_x] call _fnc_value } forEach _v;
    };

    [str _v] call _fnc_fold;
};

[GVAR(structure)] call _fnc_value;

_hash
