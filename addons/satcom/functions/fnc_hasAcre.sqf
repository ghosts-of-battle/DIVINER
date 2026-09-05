#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_satcom_fnc_hasAcre

Description:
    Is ACRE2 loaded and are the antenna functions this addon leans on actually
    there?

    Checked by function rather than by CfgPatches because that is what the
    callers use: a version of ACRE that renamed acre_sys_gsa_fnc_disconnect would
    still pass a patch test and then fail at the point of use.

Returns:
    BOOL

Author:
    Ghost
---------------------------------------------------------------------------- */

!isNil "acre_sys_gsa_fnc_isAntennaConnected"
    && {!isNil "acre_sys_gsa_fnc_hasCompatibleRadios"}
    && {!isNil "acre_sys_gsa_fnc_disconnect"}
