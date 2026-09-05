#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_scatterPosition

Description:
    Offsets a position by a random distance in a random direction, keeping the
    same height. Used to spread a stick of jumpers or a load of cargo out of a
    single drop point instead of stacking them.

Parameters:
    _position : ARRAY - centre position.
    _scatter  : ARRAY - random [min, mid, max] distance in metres.
                        (default: [5, 10, 20])

Returns:
    ARRAY - the offset position.

Author:
    Mr H. (original, MRHMilsimTools, ADPL-SA), ported by Ghost
---------------------------------------------------------------------------- */
params ["_position", ["_scatter", [5, 10, 20], [[]]]];

private _distance = random _scatter;
private _bearing = random 360;

[
    (_position select 0) + _distance * (cos _bearing),
    (_position select 1) + _distance * (sin _bearing),
    _position select 2
]
