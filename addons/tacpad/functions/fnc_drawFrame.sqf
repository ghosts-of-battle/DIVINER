#include "script_component.hpp"
/*
 * Author: Ghost
 * An outline: four edge rectangles, drawn AROUND what is inside rather than
 * behind it.
 *
 * The suite used to draw a border as one filled rectangle with a slightly
 * smaller filled rectangle on top of it. That works only while the thing inside
 * is opaque and exactly the right size, and it cannot draw an outline over an
 * accent wash at all - the inner fill covers the wash. Four edges compose with
 * whatever is underneath, which is what an outlined ROUTINE badge sitting on a
 * FLASH row needs.
 *
 * Weight is in real screen pixels. The design's rules are 1px and 2px and the
 * difference between them is the difference between a row boundary and a region
 * boundary, so it is not scaled by anything.
 *
 * Arguments:
 * 0: Parent <CONTROL>
 * 1: Position [x, y, w, h], relative to the parent <ARRAY>
 * 2: RGBA <ARRAY>
 * 3: Weight in screen pixels <NUMBER> (optional, default 1)
 *
 * Return Value:
 * The four edge controls <ARRAY>
 *
 * Example:
 * [_body, [0, 0, _w, _h], _ink, 2] call ghostD_tacpad_fnc_drawFrame
 *
 * Public: Yes
 */

params [
    ["_parent", controlNull, [controlNull]],
    ["_pos", [0, 0, 0, 0], [[]], 4],
    ["_color", [0, 0, 0, 0], [[]]],
    ["_weight", 1, [0]]
];

if (isNull _parent) exitWith {[]};

_pos params ["_x", "_y", "_w", "_h"];

private _bx = _weight * pixelW;
private _by = _weight * pixelH;

[
    [_parent, [_x, _y, _w, _by], _color] call FUNC(drawFill),
    [_parent, [_x, _y + _h - _by, _w, _by], _color] call FUNC(drawFill),
    [_parent, [_x, _y, _bx, _h], _color] call FUNC(drawFill),
    [_parent, [_x + _w - _bx, _y, _bx, _h], _color] call FUNC(drawFill)
]
