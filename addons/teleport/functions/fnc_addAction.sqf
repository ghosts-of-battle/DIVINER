#include "script_component.hpp"
/*
 * Author: Reeveli
 * Hangs the teleport action on a point. Client side - called for everyone,
 * JIP included, by FUNC(addPoint).
 *
 * Arguments:
 * 0: Object <OBJECT>
 * 1: Side that may use it <SIDE>
 *
 * Return Value:
 * Action id <NUMBER>
 *
 * Public: No
 */

params [
    ["_object", objNull, [objNull]],
    ["_side", west, [civilian]]
];

if (!hasInterface) exitWith {false};
if (isNull _object) exitWith {false};

// Read by the action's own condition below, which runs on the object rather
// than in this scope - so the side has to live on the object.
_object setVariable [QGVAR(side), _side, false];

private _text = "<t align='center'><img image='a3\ui_f_curator\data\cfgwrapperui\cursors\curatormove_ca.paa' size='2' /><br/></t><t align='center'>Teleport</t>";

_object addAction [
    _text,
    {[] call FUNC(open)},
    [_object],
    12,
    true,
    false,
    "",
    QUOTE(side _this isEqualTo (_originalTarget getVariable [ARR_2(QQGVAR(side),sideEnemy)])),
    GVAR(actionRadius),
    false,
    "",
    ""
]
