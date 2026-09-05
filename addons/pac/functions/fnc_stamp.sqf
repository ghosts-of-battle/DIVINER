#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_stamp

Description:
    A UTC timestamp string, "YYYY-MM-DD HH:MM:SS".

    EVERY RECORD CARRIES ONE and the merge rule depends on it: player data is
    last-writer-wins by updatedAt, across servers that have never spoken to each
    other. So it has to be UTC, it has to be sortable as a plain string, and it
    has to come from the real clock rather than mission time - a mission that has
    been running for six hours and one that just started must still order
    correctly against each other.

    systemTimeUTC, NOT date. `date` is the MISSION's clock, which a mission maker
    sets to 1985 if the scenario wants it, and a roster stamped in 1985 sorts
    before everything ever written.

Parameters:
    None

Returns:
    Timestamp <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

// PADDED BY HAND, not by CBA_fnc_formatNumber. PAC's own logic is vanilla
// plumbing per the handoff, and a two-digit pad is not worth the one dependency
// that would make the rule untrue.
private _fnc_pad = {
    private _n = floor (_this select 0);
    if (_n < 10) then {"0" + str _n} else {str _n}
};

systemTimeUTC params ["_y", "_m", "_d", "_h", "_min", "_s"];

format [
    "%1-%2-%3 %4:%5:%6",
    _y,
    [_m] call _fnc_pad,
    [_d] call _fnc_pad,
    [_h] call _fnc_pad,
    [_min] call _fnc_pad,
    [_s] call _fnc_pad
]
