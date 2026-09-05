#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_stampMinutes

Description:
    Turns a FUNC(stamp) string - "YYYY-MM-DD HH:MM:SS", UTC - into a count of
    minutes, so two stamps can be subtracted. Also answers the weekday, for
    the config's weekly op windows.

    ARMA HAS NO DATE ARITHMETIC. dateToNumber gives a fraction of the year
    and breaks the moment an op crosses New Year. This is Howard Hinnant's
    days_from_civil, whose epoch is 0000-03-01 (a Wednesday); only differences
    are ever used, so any epoch would do.

    Accepts "YYYY-MM-DD HH:MM" as well (seconds optional), which is the shape
    a mission maker types into opWindows[].

Parameters:
    0: Stamp <STRING>

Returns:
    [minutes, weekday] - weekday 0 = Sunday .. 6 = Saturday; [0, 0] for a
    stamp that does not parse <ARRAY>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_stamp", "", [""]]];

private _p = (_stamp splitString "-: T") apply {parseNumber _x};
if (count _p < 5) exitWith {[0, 0]};
_p params ["_y", "_m", "_d", "_hh", "_mm"];

if (_m <= 2) then {_y = _y - 1};
private _era = floor (_y / 400);
private _yoe = _y - _era * 400;
private _doy = floor ((153 * (_m + ([-3, 9] select (_m <= 2))) + 2) / 5) + _d - 1;
private _doe = _yoe * 365 + floor (_yoe / 4) - floor (_yoe / 100) + _doy;
private _days = _era * 146097 + _doe;

[(_days * 1440) + (_hh * 60) + _mm, (_days + 3) mod 7]
