#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_returnDepth

Description:
    Sea-bed depth under a position, as a negative height ASL. Probes straight
    down from sea level; returns 0 if nothing is hit.

Parameters:
    _pos : ARRAY - position, only x/y are used.

Returns:
    NUMBER - sea-bed height ASL (negative under water).

Author:
    Mr H. (original, MRHMilsimTools, ADPL-SA), ported by Ghost
---------------------------------------------------------------------------- */
params ["_pos"];

private _from = [_pos select 0, _pos select 1, 0];
private _hits = lineIntersectsSurfaces [_from, _from vectorAdd [0, 0, -4999]];

if (_hits isEqualTo []) exitWith {
    TRACE_1("no seabed found below position",_pos);
    0
};

((_hits select 0) select 0) select 2
