#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_edenDroneFactionSave

Description:
    Eden attributeSave handler for ghost_DroneFactionChoice. Returns the
    selected combo row's lbData (the faction classname STRING) to be stored
    in the SQM. Empty string if nothing is selected.

Parameters:
    _this : DISPLAY - the combo's controlsGroup display.

Returns:
    STRING - selected faction classname.

Author:
    Ghost
---------------------------------------------------------------------------- */

private _display = _this;
if (_this isEqualType []) then { _display = _this select 0 };
if (isNull _display) exitWith { "" };

private _ctrl = _display controlsGroupCtrl 100;
if (isNull _ctrl) exitWith { "" };

private _sel = lbCurSel _ctrl;
if (_sel < 0) exitWith { "" };
_ctrl lbData _sel
