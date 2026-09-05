#include "script_component.hpp"
/*
 * Author: Jacco Douma, Ghost
 * Deletes every marker this machine drew last pass.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ghostD_bft_fnc_remove
 *
 * Public: No
 */

{
    deleteMarkerLocal _x;
} forEach GVAR(markers);

GVAR(markers) = [];
