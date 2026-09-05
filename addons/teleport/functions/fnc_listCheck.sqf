#include "script_component.hpp"
/*
 * Author: Reeveli
 * Where an object sits in the point list, or -1 if it is not one.
 *
 * Arguments:
 * 0: Object <OBJECT>
 *
 * Return Value:
 * Index <NUMBER>
 *
 * Public: No
 */

params [["_object", objNull, [objNull]]];

// -1, NOT false. Every caller compares this to -1, and a boolean there reads
// as "found at the front of the list" on a type-loose comparison.
if (isNull _object) exitWith {-1};

(missionNamespace getVariable [QTP_LIST, []]) findIf {(_x # 0) isEqualTo _object}
