#include "script_component.hpp"
/*
 * Author: Ghost
 * Banks every carried intel item into this drop. THE ONLY PLACE THE COUNTER
 * MOVES - carried intel is worth nothing until it is in a case.
 *
 * Arguments:
 * 0: The drop <OBJECT>
 * 1: The player <OBJECT>
 *
 * Return Value: None
 *
 * Public: No
 */

params [["_drop", objNull, [objNull]], ["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {};

// Every kind of intel counts, and all of it goes in one deposit - a player
// who has to make three trips because he picked up three different objects
// is being punished for what the bodies happened to carry.
private _kinds = INTEL_ITEMS;
private _carried = (items _unit) select {_x in _kinds};
private _n = count _carried;
if (_n <= 0) exitWith {};

{
    _unit removeItem _x;
} forEach _carried;

[QGVAR(deposited), [_n, _unit]] call CBA_fnc_serverEvent;
