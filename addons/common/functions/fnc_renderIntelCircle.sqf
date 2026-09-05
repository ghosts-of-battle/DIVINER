#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_renderIntelCircle

Description:
    The one circle renderer every intel product uses - SIGINT hints, EW zone
    reveals, Intel Hunt hints. Products differ in the snapshot they build, never
    in how it is drawn, so they can never drift apart visually.

    Markers are placed ONCE, local to this machine, and deleted after _lifetime.
    There is no tracking loop and no per-frame handler: an intel circle is a
    snapshot of what was true when it was earned, not a live feed.

    Call it on every client that should see the circle - side filtering belongs
    to the caller, not here.

Parameters:
    _id        : STRING - unique marker name stem. Prefix it "ghost_" so
                          `#ghost markers` can find it.
    _pos       : ARRAY  - centre.
    _radius    : NUMBER - metres.
    _colour    : STRING - CfgMarkerColors class, e.g. "ColorRed".
    _alpha     : NUMBER - starting alpha. Optional, default 0.5.
    _lifetime  : NUMBER - seconds before it disappears. Optional, default 300.
    _fade      : BOOL   - false holds alpha then vanishes; true steps alpha down
                          across the lifetime. Optional, default false.
    _iconType  : STRING - optional centre icon, e.g. "mil_warning". "" = none.
    _iconText  : STRING - optional label on that icon.

Returns:
    ARRAY - the marker names created.

Example:
    ["ghost_sigint_1", _pos, 800, "ColorRed", 0.5, 300, true, "mil_warning", "JAM"] call ghostD_common_fnc_renderIntelCircle

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_id", "", [""]], ["_pos", [0,0,0], [[]]], ["_radius", 300, [0]],
        ["_colour", "ColorRed", [""]], ["_alpha", 0.5, [0]], ["_lifetime", 300, [0]],
        ["_fade", false, [false]], ["_iconType", "", [""]], ["_iconText", "", [""]]];

if (!hasInterface || _id isEqualTo "") exitWith { [] };

private _made = [];

// A RING, NOT A DISC. A filled ellipse hides the map underneath it, which is
// the one thing a player needs to read once they know roughly where to look;
// and several overlapping fills turn the map into soup. "Border" draws the
// outline only.
//
// The colour is drawn per circle rather than fixed, so two products up at once
// are told apart at a glance instead of merging into one red smear. Passing an
// explicit colour still wins - the caller knows when a colour means something.
if (_colour isEqualTo "") then {
    _colour = selectRandom INTEL_CIRCLE_COLOURS;
};

private _area = createMarkerLocal [_id, _pos];
_area setMarkerShapeLocal "ELLIPSE";
_area setMarkerBrushLocal "Border";
_area setMarkerSizeLocal [_radius, _radius];
_area setMarkerColorLocal _colour;
_area setMarkerAlphaLocal _alpha;
_made pushBack _area;

if (_iconType isNotEqualTo "") then {
    private _icon = createMarkerLocal [_id + "_icon", _pos];
    _icon setMarkerTypeLocal _iconType;
    _icon setMarkerColorLocal _colour;
    _icon setMarkerAlphaLocal _alpha;
    if (_iconText isNotEqualTo "") then { _icon setMarkerTextLocal _iconText };
    _made pushBack _icon;
};

// Fade is a handful of scheduled steps, never a per-frame handler.
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
    [{
        { deleteMarkerLocal _x } forEach _this;
    }, _made, _lifetime] call CBA_fnc_waitAndExecute;
};

_made
