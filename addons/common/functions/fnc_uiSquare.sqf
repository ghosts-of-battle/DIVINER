#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_uiSquare

Description:
    How much narrower a control has to be, per unit of height, to come out
    physically square.

    Arma lays UI controls out in safeZone units. On a stock 16:9 setup
    safeZoneW / safeZoneH happens to equal the display aspect, so a UI unit is
    the same number of pixels across as it is down and equal w and h give a
    square control. That is NOT guaranteed: interface size, the safe-zone
    sliders and a video aspect setting that disagrees with the monitor all shift
    safeZoneW independently of the resolution, and then equal w and h render as
    a rectangle - by a factor of about 1.35 on some setups.

    That matters wherever art has to keep its proportions. A photograph of a
    device stretched 35% wide reads as a broken model, and anything positioned
    as a fraction of that control - the lit screen inside a bezel, say - drifts
    off the art it was measured against.

    So: give the control a height, multiply it by this, use that as the width.

Returns:
    NUMBER - multiply a height (in safeZone units) by this to get the width of a
             physically square control. 1 on a stock 16:9 setup.

Example:
    private _h = 0.9 * safeZoneH;
    private _w = _h * (call ghostD_common_fnc_uiSquare);        // square
    private _w = _h * 0.6 * (call ghostD_common_fnc_uiSquare);  // 0.6:1 portrait

Author:
    Ghost
---------------------------------------------------------------------------- */

// getResolution: [w, h, viewportW, viewportH, aspectRatio, uiScale]. Element 4
// is the aspect Arma is actually rendering at, which is what safeZoneW has to be
// measured against.
private _aspect = getResolution select 4;
if (_aspect <= 0) exitWith { 1 };

safeZoneW / safeZoneH / _aspect
