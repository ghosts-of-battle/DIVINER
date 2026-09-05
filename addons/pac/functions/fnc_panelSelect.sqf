#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelSelect

Description:
    The roster list's onLBSelChanged. Asks the server for the full record of
    the player clicked; the answer comes back through FUNC(adminRecv) and
    fills the page. Meanwhile the page shows the row as loading.

    Silent while the roster is being refilled, because a refill re-selects
    the open row and that is not a new click.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
if (GVAR(panelFilling)) exitWith {};

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

private _list = _display displayCtrl PAC_IDC_L_LIST;
private _sel = lbCurSel _list;
if (_sel < 0) exitWith {};

private _uid = _list lbData _sel;
if (_uid isEqualTo "") exitWith {};

GVAR(editUid) = _uid;
GVAR(editRecord) = createHashMap;
[] call FUNC(panelFill);

[player, _uid] remoteExec [QFUNC(adminGet), 2];
