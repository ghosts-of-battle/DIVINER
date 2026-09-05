#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_scannerLayout

Description:
    Places the handset at the player's saved position and lays the screen out on
    a fixed line grid. Like every ghost HUD it can be dragged somewhere else - a
    device you hold should not be stuck where someone else thought it belonged.

    Everything is derived from one number, SCN_H, so the device scales as a unit
    and the type always fits the glass: font height comes from the row height
    rather than from a config constant that only happened to look right on one
    monitor. That was the old screen's problem.

Parameters:
    _display : DISPLAY - the scanner layer.

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_display"];

// Height drives everything; EFUNC(common,uiSquare) turns a physical aspect into
// a UI width, so the handset keeps its shape on any setup. Get this wrong and
// not only does the art shear, the screen rectangle - which is measured as a
// fraction of the art - slides off the glass and onto the bezel.
private _h = SCN_H * safeZoneH;
private _w = _h * SCN_ASPECT * (call EFUNC(common,uiSquare));

// POSITION IS THE GAME'S JOB. This read ghost's own drag-and-save, which meant
// the handset was moved by a ghost-specific gesture and knew nothing about where
// the player had put anything else. It is registered as an IGUI grid now - see
// CfgUIGrids.hpp - so it is dragged in Options > Game > Layout with the HUD
// slots and the stamina bar.
//
// The class name's case is carried into the variable exactly, which is the trap
// that cost two attempts on the HUD: grid_ghost_scanner, not GRID_GHOST_SCANNER.
private _x = profileNamespace getVariable ["IGUI_grid_ghost_scanner_X", safeZoneX + safeZoneW * SCN_DEF_X];
private _y = profileNamespace getVariable ["IGUI_grid_ghost_scanner_Y", safeZoneY + safeZoneH * SCN_DEF_Y];

// A position saved on a wider screen must not put the handset off this one.
_x = (safeZoneX) max (_x min (safeZoneX + safeZoneW - _w));
_y = (safeZoneY) max (_y min (safeZoneY + safeZoneH - _h));

(_display displayCtrl IDC_SCN_BEZEL) ctrlSetPosition [_x, _y, _w, _h];

// The glass inside the art. Nothing is drawn here - it is the box the text is
// laid out in, and the art supplies its own black.
private _sx = _x + _w * SCN_SCR_X;
private _sy = _y + _h * SCN_SCR_Y;
private _sw = _w * SCN_SCR_W;
private _sh = _h * SCN_SCR_H;

// One row of the terminal. A margin inside the glass keeps the text off the
// edge without shrinking the grid.
private _pad = _sw * 0.06;
private _tx = _sx + _pad;
private _tw = _sw - _pad * 2;
private _rowH = _sh / SCN_ROWS;
private _fh = _rowH * 0.78;

// A glyph gutter down the left of the reading rows. Square, because every icon
// was cut onto a square canvas.
private _icoW = _rowH * 0.86;
private _gutter = _icoW * 1.25;

// row -> [icon or -1, controls on that line]. The blank rows are deliberate: a
// terminal that fills every line is a wall, and the gaps are what make the
// blocks read as blocks.
private _rows = [
    [1, -1, [IDC_SCN_TITLE]],
    [3, IDC_SCN_ICO_DRONE, [IDC_SCN_DRONE_L, IDC_SCN_DRONE_V]],
    [4, IDC_SCN_ICO_JAM, [IDC_SCN_JAM_L, IDC_SCN_JAM_V]],
    [5, IDC_SCN_ICO_MESH, [IDC_SCN_MESH_L, IDC_SCN_MESH_V]],
    [7, -1, [IDC_SCN_NETHEAD]],
    [8, IDC_SCN_ICO_NET, [IDC_SCN_NET_L, IDC_SCN_NET_V]],
    [9, -1, [IDC_SCN_ALARM]],
    [10, -1, [IDC_SCN_TIMER]],
    [11, -1, [IDC_SCN_STATUS]]
];

// _x is the panel origin, so the loops name their element to avoid shadowing it.
{
    _x params ["_row", "_ico", "_idcs"];
    private _ry = _sy + _row * _rowH;

    // Rows with a glyph give up the gutter; the centred lines keep the full
    // width so they stay centred on the screen rather than on what is left of
    // it.
    private _lx = _tx;
    private _lw = _tw;
    if (_ico != -1) then {
        private _ctrl = _display displayCtrl _ico;
        _ctrl ctrlSetPosition [_tx, _ry + (_rowH - _icoW) / 2, _icoW, _icoW];
        _ctrl ctrlCommit 0;
        _lx = _tx + _gutter;
        _lw = _tw - _gutter;
    };

    {
        private _ctrl = _display displayCtrl _x;
        // Both halves of a reading span the same box; the style (left or right)
        // is what separates them, so a long value never overlaps its label and
        // neither ever needs padding to line up.
        _ctrl ctrlSetPosition [_lx, _ry, _lw, _rowH];
        _ctrl ctrlSetFontHeight _fh;
        _ctrl ctrlCommit 0;
    } forEach _idcs;
} forEach _rows;

(_display displayCtrl IDC_SCN_BEZEL) ctrlCommit 0;

// Static furniture. The rules are text rather than art so they sit on the same
// grid as everything else and scale with it.
(_display displayCtrl IDC_SCN_TITLE) ctrlSetText "== SCANNER ==";
(_display displayCtrl IDC_SCN_NETHEAD) ctrlSetText "==== NET ====";
(_display displayCtrl IDC_SCN_DRONE_L) ctrlSetText "UAV";
(_display displayCtrl IDC_SCN_JAM_L) ctrlSetText "JAM";
(_display displayCtrl IDC_SCN_MESH_L) ctrlSetText "MESH";
// The net row's label is the channel itself, so FUNC(scannerTick) owns it.
