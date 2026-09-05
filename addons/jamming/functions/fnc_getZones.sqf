#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_jamming_fnc_getZones

Description:
    The public zone API. This is the ONLY cross-addon surface - no other addon
    reads the registry array directly, so the entry layout stays free to change.

    Jam zones are real emitters, one entry each. Detection has no zone objects at
    all: it is a range tested around every live emitter, so the whole detection
    net is returned as ONE synthetic covering circle (D35), recomputed here from
    the live emitters. Recon drones are deliberately not folded in (D36) - they
    move, and intel markers are snapshots.

    Dead emitters are filtered here rather than tracked, so the answer is always
    current and the caller never sees an object reference.

Parameters:
    _type        : STRING - "jam", "detect" or "all". Optional, default "all".
    _excludeIds  : ARRAY  - ids to omit. Optional, default [].
    _includeTemp : BOOL   - include temp zones. Optional, default true.

Returns:
    ARRAY - [[_id, _type, _pos, _radius, _isTemp], ...]

Example:
    ["jam", GVAR(spentZones), false] call ghostD_jamming_fnc_getZones

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_type", "all", [""]], ["_excludeIds", [], [[]]], ["_includeTemp", true, [false]]];

private _reg = missionNamespace getVariable [QGVAR(jammers), []];
private _out = [];

private _live = _reg select {
    private _o = _x param [ZONE_OBJ, objNull];
    (isNull _o || {alive _o}) && {(_x param [ZONE_TEMP, false]) || true}
};

if (_type in ["jam", "all"]) then {
    {
        private _isTemp = _x param [ZONE_TEMP, false];
        if (!_includeTemp && _isTemp) then { continue };
        private _id = _x param [ZONE_ID, ""];
        if (_id isEqualTo "" || {_id in _excludeIds}) then { continue };
        private _o = _x param [ZONE_OBJ, objNull];
        _out pushBack [
            _id, "jam",
            if (isNull _o) then { _x param [ZONE_POS, [0,0,0]] } else { getPosASL _o },
            _x param [ZONE_RFALL, 0],
            _isTemp
        ];
    } forEach _live;
};

// One covering circle over the fixed detection net, or nothing if it is gone.
if (_type in ["detect", "all"] && {!(DETECT_NET_ID in _excludeIds)}) then {
    private _emitters = _live select {
        !isNull (_x param [ZONE_OBJ, objNull]) && {!(_x param [ZONE_TEMP, false])}
    };
    if (_emitters isNotEqualTo []) then {
        private _positions = _emitters apply { getPosASL (_x select ZONE_OBJ) };
        private _cx = 0;
        private _cy = 0;
        { _cx = _cx + (_x select 0); _cy = _cy + (_x select 1) } forEach _positions;
        private _n = count _positions;
        private _centre = [_cx / _n, _cy / _n, 0];
        private _spread = 0;
        { _spread = _spread max (_centre distance2D _x) } forEach _positions;
        _out pushBack [DETECT_NET_ID, "detect", _centre, _spread + GVAR(detectorRange), false];
    };
};

_out
