#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_notify_fnc_place

Description:
    Puts one slot's three controls - panel, colour bar and text - on a given row
    and sizes its type. Both FUNC(show) and FUNC(tick) need this: one to place a
    new notification, the other to slide the survivors down when a gap opens.
    Having it in one place is what stops the two drifting apart.

    Nothing is committed here. The caller decides whether the move is instant
    (a new notification appearing) or animated (the stack closing up).

Parameters:
    _display : DISPLAY - the notification layer.
    _slot    : NUMBER  - which pre-built slot.
    _row     : NUMBER  - 0-based position in the stack.

Returns:
    ARRAY - the three control handles, in paint order.

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_display", "_slot", "_row"];

([_row] call FUNC(layout)) params ["_x", "_y", "_w", "_h", "_fh"];

private _panel = _display displayCtrl IDC_SLOT(_slot);
private _bar   = _display displayCtrl IDC_BAR(_slot);
private _txt   = _display displayCtrl IDC_TEXT(_slot);

// The bar and the insets are proportional to the type as well, so the whole row
// scales as one piece rather than a big label in a thin frame.
private _barW = _fh * 0.22;
private _insetX = _fh * 0.4;
private _insetY = _fh * 0.25;

_panel ctrlSetPosition [_x, _y, _w, _h];
_bar   ctrlSetPosition [_x, _y, _barW, _h];
_txt   ctrlSetPosition [
    _x + _barW + _insetX, _y + _insetY,
    _w - _barW - _insetX * 2, _h - _insetY * 2
];
_txt ctrlSetFontHeight _fh;

[_panel, _bar, _txt]
