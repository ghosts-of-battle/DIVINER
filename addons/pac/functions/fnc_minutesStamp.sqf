#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_minutesStamp

Description:
    The inverse of FUNC(stampMinutes): a count of minutes back into
    "YYYY-MM-DD HH:MM". Howard Hinnant's civil_from_days, same epoch
    (0000-03-01), so the two round-trip.

Parameters:
    0: Minutes <NUMBER>

Returns:
    "YYYY-MM-DD HH:MM" <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_minutes", 0, [0]]];

private _days = floor (_minutes / 1440);
private _rest = _minutes - (_days * 1440);

private _era = floor (_days / 146097);
private _doe = _days - _era * 146097;
private _yoe = floor ((_doe - floor (_doe / 1460) + floor (_doe / 36524) - floor (_doe / 146096)) / 365);
private _y = _yoe + _era * 400;
private _doy = _doe - (365 * _yoe + floor (_yoe / 4) - floor (_yoe / 100));
private _mp = floor ((5 * _doy + 2) / 153);
private _d = _doy - floor ((153 * _mp + 2) / 5) + 1;
private _m = _mp + ([3, -9] select (_mp >= 10));
if (_m <= 2) then {_y = _y + 1};

private _fnc_pad = {
    params ["_n"];
    (["", "0"] select (_n < 10)) + str _n
};

format ["%1-%2-%3 %4:%5", _y, [_m] call _fnc_pad, [_d] call _fnc_pad, [floor (_rest / 60)] call _fnc_pad, [_rest mod 60] call _fnc_pad]
