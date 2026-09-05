#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_tabletSelectIntel

Description:
    Picks which intel the hack will pull. The choice is made BEFORE the hack now,
    not offered afterwards: you decide what you are going in for, and the run
    either gets it or it does not.

Parameters:
    _slot : NUMBER - intel button index.

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_slot"];

if (_slot < 0) exitWith {};
if (GVAR(session) get "running") exitWith {};

private _avail = GVAR(intelAvailable);
if (_slot >= count _avail) exitWith {};

GVAR(session) set ["intel", (_avail select _slot) select 0];

