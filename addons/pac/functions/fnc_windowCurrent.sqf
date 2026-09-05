#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_windowCurrent

Description:
    Which op window is on right now, as an id, or "" for none. Server only -
    it reads the manual window and the settings.

    THREE SOURCES, IN THE HANDOFF'S ORDER:

        manual   an admin pressed START            -> the row's id, "w2026..."
        config   settings opWindows[] has one on   -> "cfg:<index>:<date>"
        opord    settings currentOpord is set      -> "opord:<opordId>"

    A manual window beats the config, which beats the OPORD, because each is
    a more deliberate statement than the one below it. The first that answers
    wins.

    CONFIG WINDOWS ARE NEVER STORED. opWindows[] entries are either weekly -
    {dow, "HH:MM", "HH:MM"}, dow a number 0 = Sunday .. 6 or a name - or
    absolute - {"YYYY-MM-DD HH:MM", "YYYY-MM-DD HH:MM"}. Both are answered by
    looking at the clock. A weekly window's id carries the date it STARTED on,
    so each week's sessions are their own window and a player who joins after
    midnight is still in the same one as those who joined before it; a window
    whose end is not after its start is taken to run into the next day.

    ATTENDANCE IS STAMPED AT JOIN with what this returns, and the report
    groups by that. So a forgotten START button is not lost - the config or
    OPORD window was recorded anyway, and the manual one only adds precision.

Parameters:
    None

Returns:
    Window id, "" for none <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

if (!isServer) exitWith {""};

// ---- manual ----------------------------------------------------------------
if (GVAR(windowOpen) isNotEqualTo "") exitWith {GVAR(windowOpen)};

// ---- config ----------------------------------------------------------------
([[] call FUNC(stamp)] call FUNC(stampMinutes)) params ["_nowMin", "_dow"];
private _dayMin = _nowMin - (_nowMin mod 1440);

private _fnc_dow = {
    params ["_v"];
    if (_v isEqualType 0) exitWith {_v};
    ["sun", "mon", "tue", "wed", "thu", "fri", "sat"] find (toLower (_v select [0, 3]))
};
private _fnc_minOfDay = {
    params ["_hhmm"];
    private _p = (_hhmm splitString ":") apply {parseNumber _x};
    ((_p param [0, 0]) * 60) + (_p param [1, 0])
};

private _hit = "";
{
    private _entry = _x;
    private _i = _forEachIndex;
    if !(_entry isEqualType []) then {continue};

    switch (count _entry) do {
        case 3: {
            _entry params ["_d", "_from", "_to"];
            private _wd = [_d] call _fnc_dow;
            private _fromMin = [_from] call _fnc_minOfDay;
            private _length = (([_to] call _fnc_minOfDay) - _fromMin);
            if (_length <= 0) then {_length = _length + 1440};

            // The occurrence that started today, or the one that started
            // yesterday and runs past midnight - whichever holds now.
            {
                private _offset = _x;
                private _start = _dayMin + (_offset * 1440) + _fromMin;
                if (_wd isEqualTo ((_dow + _offset + 7) mod 7) && _nowMin >= _start && _nowMin < _start + _length) exitWith {
                    _hit = format ["cfg:%1:%2", _i, ([_start] call FUNC(minutesStamp)) select [0, 10]];
                };
            } forEach [0, -1];
        };
        case 2: {
            _entry params ["_from", "_to"];
            private _fromMin = ([_from] call FUNC(stampMinutes)) # 0;
            private _toMin = ([_to] call FUNC(stampMinutes)) # 0;
            if (_nowMin >= _fromMin && _nowMin < _toMin) then {
                _hit = format ["cfg:%1", _i];
            };
        };
    };
    if (_hit isNotEqualTo "") exitWith {};
} forEach (GVAR(settings) getOrDefault ["opWindows", []]);

if (_hit isNotEqualTo "") exitWith {_hit};

// ---- opord -----------------------------------------------------------------
private _opord = GVAR(settings) getOrDefault ["currentOpord", ""];
if (_opord isNotEqualTo "") exitWith {"opord:" + _opord};

""
