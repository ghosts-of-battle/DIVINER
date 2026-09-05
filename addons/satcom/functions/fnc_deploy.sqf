#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_satcom_fnc_deploy

Description:
    Plants the mast a couple of metres in front of the operator, sitting flat on
    whatever it lands on.

    The item leaves the inventory first and the mast appears after the animation,
    so the two never coexist - you cannot start the deploy and then run off still
    carrying it.

    The surface trace is what stops the dish hovering over a slope or sinking
    into a hillside: it takes the ground's own normal and stands the mast up
    along it, rather than assuming the world is flat where you happen to be.

Parameters:
    _unit : OBJECT - the operator.

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_unit"];

if !([_unit] call FUNC(canDeploy)) exitWith {};

_unit removeItem QGVAR(item);

if (stance _unit isEqualTo "STAND") then {
    [_unit, "AmovPercMstpSrasWrflDnon_diary"] call ace_common_fnc_doAnimation;
};

[{
    params ["_unit"];

    private _dir = getDir _unit;
    private _pos = (getPosASL _unit) vectorAdd
        [SATCOM_PLACE_DIST * sin _dir, SATCOM_PLACE_DIST * cos _dir, 0];
    private _up = [0, 0, 1];

    // Trace straight down through where it is going to stand.
    private _hits = lineIntersectsSurfaces [
        _pos vectorAdd [0, 0, 1.5],
        _pos vectorDiff [0, 0, 1.5],
        _unit, objNull, true, 1, "GEOM", "FIRE"
    ];
    if (_hits isNotEqualTo []) then {
        (_hits select 0) params ["_touch", "_normal"];
        _pos = _touch;
        _up = _normal;
    };

    private _mast = createVehicle [QGVAR(deployed), [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _mast setDir _dir;
    _mast setPosASL _pos;
    _mast setVectorUp _up;
}, [_unit], SATCOM_PLACE_TIME] call CBA_fnc_waitAndExecute;
