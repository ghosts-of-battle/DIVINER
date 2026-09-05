#include "script_component.hpp"
/*
 * Author: Jacco Douma, Ghost
 * Takes a group off every network it transmits on.
 *
 * Arguments:
 * 0: Group <GROUP>
 *
 * Return Value:
 * The group's transmit list, empty <ARRAY>
 *
 * Example:
 * [group this] call ghostD_bft_fnc_networkClear
 *
 * Public: Yes
 */

params [["_group", grpNull, [grpNull]]];

[_group, "*"] call FUNC(networkRemove)
