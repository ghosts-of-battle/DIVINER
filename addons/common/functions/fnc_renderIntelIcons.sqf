#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_renderIntelIcons

Description:
    Icon-marker counterpart to FUNC(renderIntelCircle), for products that plot
    contacts rather than an area - the Local Picture. Same snapshot rules: placed
    once, local, no tracking, gone after _lifetime.

    Rows are drawn with no text label. An intel picture shows you what was where,
    not what it was called.

Parameters:
    _id       : STRING - marker name stem, prefix "ghost_".
    _rows     : ARRAY  - [[_pos, _iconType], ...].
    _colour   : STRING - CfgMarkerColors class.
    _alpha    : NUMBER - optional, default 1.
    _lifetime : NUMBER - optional, default 300.
    _fade     : BOOL   - optional, default false.

Returns:
    ARRAY - the marker names created.

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_id", "", [""]], ["_rows", [], [[]]], ["_colour", "ColorRed", [""]],
        ["_alpha", 1, [0]], ["_lifetime", 300, [0]], ["_fade", false, [false]]];

if (!hasInterface || {_id isEqualTo "" || {_rows isEqualTo []}}) exitWith { [] };

private _made = [];
{
    _x params ["_pos", ["_type", "hd_dot"]];
    private _m = createMarkerLocal [format ["%1_%2", _id, _forEachIndex], _pos];
    _m setMarkerTypeLocal _type;
    _m setMarkerColorLocal _colour;
    _m setMarkerAlphaLocal _alpha;
    _made pushBack _m;
} forEach _rows;

if (_fade && _lifetime > 0) then {
    private _steps = INTEL_FADE_STEPS;
    for "_i" from 1 to _steps do {
        [{
            params ["_markers", "_a"];
            { _x setMarkerAlphaLocal _a } forEach _markers;
        }, [_made, _alpha * (1 - (_i / _steps))], _lifetime * (_i / _steps)] call CBA_fnc_waitAndExecute;
    };
};

if (_lifetime > 0) then {
    [{ { deleteMarkerLocal _x } forEach _this }, _made, _lifetime] call CBA_fnc_waitAndExecute;
};

_made
