#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_setCtrlHeightToText

Description:
    Shrinks or grows a control's height to exactly fit the text it holds, so
    wrapped strings do not overflow or leave a gap. Renamed from the original's
    `SetCtrlSize`.

Parameters:
    _displayIDD : NUMBER - display the control lives on.
    _ctrlIDC    : NUMBER - the control.

Returns:
    Nothing.

Author:
    Mr H. (original, MRHMilsimTools, ADPL-SA), ported by Ghost
---------------------------------------------------------------------------- */
params ["_displayIDD", "_ctrlIDC"];

private _ctrl = (findDisplay _displayIDD) displayCtrl _ctrlIDC;
if (isNull _ctrl) exitWith {};

(ctrlPosition _ctrl) params ["_x", "_y", "_w"];
_ctrl ctrlSetPosition [_x, _y, _w, ctrlTextHeight _ctrl];
_ctrl ctrlCommit 0;
