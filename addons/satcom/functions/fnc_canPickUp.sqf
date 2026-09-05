#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_satcom_fnc_canPickUp

Description:
    May this mast be packed up?

    No, if it is holding a patrol base together. patrol_base spawns one of these
    as its beacon and hangs the Unbuild action on it, so packing it away would
    delete the base's anchor and leave a base nobody can take down. The variable
    name is a literal here rather than an import - this addon does not depend on
    patrol_base, it just refuses to undermine it.

    No, if there is no room for the item either. Better to say so up front than
    to play the animation and then find out.

Parameters:
    _unit   : OBJECT - the player.
    _target : OBJECT - the mast.

Returns:
    BOOL

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_unit", "_target"];

if (isNull _target) exitWith { false };
if (_target getVariable [SATCOM_BASE_VAR, false]) exitWith { false };

_unit canAdd QGVAR(item)
