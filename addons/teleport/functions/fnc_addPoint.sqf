#include "script_component.hpp"
/*
 * Author: Reeveli
 * Makes an object a teleport point. Server side: run it from an Eden init
 * field (which runs everywhere, and the server check below picks the one that
 * counts) or remoteExec it to the server.
 *
 * Arguments:
 * 0: Object <OBJECT>
 * 1: Display name <STRING>
 * 2: Side that may use it <SIDE>
 *
 * Return Value: None
 *
 * Example:
 * [this, "Staging area", west] call ghostD_teleport_fnc_addPoint
 *
 * Public: Yes
 */

params [
    ["_object", objNull, [objNull]],
    ["_name", "", [""]],
    ["_side", west, [civilian]]
];

if (!isServer) exitWith {false};
if (isNull _object) exitWith {false};

if (([_object] call FUNC(listCheck)) > -1) exitWith {
    WARNING_1("'%1' is already a teleport point",_object);
    false
};

private _list = missionNamespace getVariable [QTP_LIST, []];
_list pushBack [_object, _name, _side];
missionNamespace setVariable [QTP_LIST, _list, true];

// The point goes when the object does, so a destroyed shed does not stay on
// the list as somewhere you can still be sent.
_object addEventHandler ["Killed", {
    params ["_unit"];
    [_unit] call FUNC(deletePoint);
}];

_object addEventHandler ["Deleted", {
    params ["_entity"];
    [_entity] call FUNC(deletePoint);
}];

[_object, _side] remoteExecCall [QFUNC(addAction), 0, true];
