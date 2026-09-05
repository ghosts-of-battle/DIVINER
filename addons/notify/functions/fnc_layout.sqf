#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_notify_fnc_layout

Description:
    Screen rectangle for a stack row, honouring the corner, width and text size
    settings. Row 0 is always the one nearest the chosen corner; on a bottom
    corner the stack therefore grows upward.

    Row height comes from the font height rather than the other way round, so
    turning the text up makes the notification taller instead of squeezing two
    lines into a box that was sized for smaller type.

Parameters:
    _row : NUMBER - 0-based position in the stack.

Returns:
    ARRAY - [x, y, w, h, fontHeight]

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_row"];

private _fh = FONT_BASE * GVAR(fontSize) * safeZoneH;
private _w = GVAR(width) * safeZoneW;
private _h = _fh * ROW_LINES;
private _gap = _fh * ROW_GAP;
private _pad = 0.02 * safeZoneW;

private _corner = GVAR(corner);
private _left = _corner in [0, 2];
private _top = _corner in [0, 1];

private _x = if (_left) then { safeZoneX + _pad } else { safeZoneX + safeZoneW - _pad - _w };
private _y = if (_top) then {
    safeZoneY + 0.08 * safeZoneH + _row * (_h + _gap)
} else {
    safeZoneY + safeZoneH - 0.08 * safeZoneH - _h - _row * (_h + _gap)
};

[_x, _y, _w, _h, _fh]
