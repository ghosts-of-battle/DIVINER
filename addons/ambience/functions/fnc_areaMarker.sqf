#include "script_component.hpp"
/*
 * Author: YonV
 * Turns a module's own drawn area into a marker, so everything downstream can
 * carry on asking about markers.
 *
 * WHY A MARKER AND NOT A NEW SHAPE OF ANSWER. Both ambience modules hand their
 * area to FUNC(pickBuilding) and FUNC(kamikazeRun), and both of those hand it to
 * EFUNC(common,taorGate), which takes marker names because that is what a TAOR
 * was. Teaching four functions a second way to describe an area - and leaving
 * two of them able to disagree about whether a position is inside one - is a
 * worse change than making the module's rectangle into the thing they already
 * understand.
 *
 * LOCAL TO THE SERVER, which is where it is asked about. Both modules run their
 * schedulers on the server and the gate they feed runs there too, so a global
 * marker would be four network updates and a box on forty clients' maps to
 * answer a question only one machine ever asks. Alpha 0 as well, because a
 * server-side box is still a box if anybody ever looks.
 *
 * A MODULE NEVER RESIZED HAS NO AREA, and that is not an error - it is the old
 * behaviour, which is "anywhere near a player". Nothing is created and the
 * caller's own marker list stands.
 *
 * Arguments:
 * 0: The module logic <OBJECT>
 * 1: A tag for the marker name, so two modules cannot collide <STRING>
 *
 * Return Value:
 * The marker name, or "" when the module was never resized <STRING>
 *
 * Public: No
 */

params [["_logic", objNull, [objNull]], ["_tag", "amb", [""]]];

if (isNull _logic) exitWith {""};

(_logic getVariable ["objectArea", [0, 0, 0, false, 0]]) params
    [["_a", 0], ["_b", 0], ["_angle", 0], ["_rect", false]];

if (_a <= 0 || _b <= 0) exitWith {""};

private _name = format [QGVAR(area_%1_%2), _tag, round (random 1e6)];
private _marker = createMarkerLocal [_name, getPosATL _logic];
if (_marker isEqualTo "") exitWith {""};

_marker setMarkerShapeLocal (["ELLIPSE", "RECTANGLE"] select _rect);
_marker setMarkerSizeLocal [_a, _b];
_marker setMarkerDirLocal _angle;
_marker setMarkerAlphaLocal 0;

TRACE_3("ambience area marker",_name,_a,_b);

_marker
