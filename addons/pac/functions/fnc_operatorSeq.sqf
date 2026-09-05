#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_operatorSeq

Description:
    The next operator id - "OP-10001", "OP-10002" ... - from a counter kept
    in the store's meta, skipping any id a record already holds (an
    imported store may carry its own). Server only. An operator id is
    given once and never reused: it is the number the unit knows a person
    by, and it outlives their Arma name.

Parameters:
    None

Returns:
    The id <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

if (!isServer) exitWith {""};

private _taken = [];
{
    private _op = _y getOrDefault ["operatorId", ""];
    if (_op isNotEqualTo "") then {_taken pushBack _op};
} forEach GVAR(players);

private _seq = GVAR(meta) getOrDefault ["operatorSeq", 10000];
private _id = "";
while {_id isEqualTo "" || {_id in _taken}} do {
    _seq = _seq + 1;
    _id = "OP-" + str _seq;
};
GVAR(meta) set ["operatorSeq", _seq];

_id
