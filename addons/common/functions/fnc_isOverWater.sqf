#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_isOverWater

Description:
    Is this position over water? Uses isFlatEmpty with the water flag rather
    than surfaceIsWater, so it agrees with what a helicopter would find trying
    to set down there. Renamed from the original's `lzIsOnWater`.

Parameters:
    _pos : ARRAY - position to test.

Returns:
    BOOL

Author:
    Mr H. (original, MRHMilsimTools, ADPL-SA), ported by Ghost
---------------------------------------------------------------------------- */
params ["_pos"];

(_pos isFlatEmpty [-1, -1, -1, -1, 2, false]) isNotEqualTo []
