#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_realisticGrid

Description:
    Map grid reference for a position, formatted "easting-northing", using ACE's
    grid conversion so it matches what players read off the map.

Parameters:
    _position : ARRAY

Returns:
    STRING

Author:
    Mr H. (original, MRHMilsimTools, ADPL-SA), ported by Ghost
---------------------------------------------------------------------------- */
params ["_position"];

([_position] call ace_common_fnc_getMapGridFromPos) joinString "-"
