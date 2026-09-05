#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelUnassigned

Description:
    Toggles the roster between everyone and only the players nobody has
    assigned anything to - no rank, no role, no skills. The button is painted
    in the accent while the filter is on.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
GVAR(panelUnassigned) = !GVAR(panelUnassigned);

private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (!isNull _display) then {
    ([] call EFUNC(tacpad,theme)) params ["_ground", "_ink", "_accent"];
    private _btn = _display displayCtrl PAC_IDC_L_UNASSIGNED;
    if (GVAR(panelUnassigned)) then {
        _btn ctrlSetBackgroundColor [_accent # 0, _accent # 1, _accent # 2, 1];
        _btn ctrlSetTextColor [_ground # 0, _ground # 1, _ground # 2, 1];
    } else {
        _btn ctrlSetBackgroundColor [_ground # 0, _ground # 1, _ground # 2, 1];
        _btn ctrlSetTextColor [_ink # 0, _ink # 1, _ink # 2, 1];
    };
};

[] call FUNC(panelFillRoster);
