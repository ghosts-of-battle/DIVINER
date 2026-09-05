#include "..\script_component.hpp"
/*
 * Author: YonV
 * Removes a number of one bag class from a unit, where that unit is local.
 *
 * WHY THIS EXISTS AT ALL. removeItem is a local command: run against a unit
 * that belongs to another machine it returns quietly and changes nothing, and
 * FUNC(doTake) would then hand the player a bag the casualty still has. This is
 * the half that has to travel, kept to one job so the remoteExec payload is
 * three values and no logic.
 *
 * Arguments:
 * 0: Casualty <OBJECT>
 * 1: Item class <STRING>
 * 2: How many <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]], ["_item", "", [""]], ["_count", 1, [0]]];

if (isNull _unit || _item isEqualTo "" || {!local _unit}) exitWith {};

for "_i" from 1 to _count do {
    _unit removeItem _item;
};
