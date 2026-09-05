#include "script_component.hpp"
/*
 * Author: Reeveli
 * Takes an object off the point list. Runs anywhere - the list is published
 * from wherever it is changed - but keep it off global execution.
 *
 * Arguments:
 * 0: Object <OBJECT>
 *
 * Return Value: None
 *
 * Public: Yes
 */

params [["_object", objNull, [objNull]]];

if (isNull _object) exitWith {false};

private _index = [_object] call FUNC(listCheck);

// NOT FOUND IS NOT AN INDEX. deleteAt -1 takes the LAST entry off the list,
// so an object that was never a point - or one whose Killed and Deleted
// handlers both fire - used to remove somebody else's.
if (_index < 0) exitWith {false};

private _list = missionNamespace getVariable [QTP_LIST, []];
_list deleteAt _index;
missionNamespace setVariable [QTP_LIST, _list, true];
