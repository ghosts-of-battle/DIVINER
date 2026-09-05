#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_manageStyle

Description:
    Paints the management window from the player's tacpad scheme, the way
    FUNC(panelStyle) paints the admin page - so the three PAC screens are
    one family.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(manageDisplay), displayNull];
if (isNull _display) exitWith {};

([] call EFUNC(tacpad,theme)) params ["_ground", "_ink", "_accent"];
private _opacity = ((missionNamespace getVariable [QEGVAR(tacpad,opacity), 0.92]) max 0.88) min 1;
private _base = [_ground # 0, _ground # 1, _ground # 2, _opacity];
private _lift = [((_ground # 0) * 0.82) + ((_ink # 0) * 0.18), ((_ground # 1) * 0.82) + ((_ink # 1) * 0.18), ((_ground # 2) * 0.82) + ((_ink # 2) * 0.18), _opacity];
private _inkFull = [_ink # 0, _ink # 1, _ink # 2, 1];
private _mute = [_ink # 0, _ink # 1, _ink # 2, 0.62];
private _accentFull = [_accent # 0, _accent # 1, _accent # 2, 1];

private _fnc_paint = {
    params ["_idcs", "_bg", "_fg"];
    {
        private _ctrl = _display displayCtrl _x;
        if (isNull _ctrl) then {continue};
        if (!isNil "_bg") then {_ctrl ctrlSetBackgroundColor _bg};
        if (!isNil "_fg") then {_ctrl ctrlSetTextColor _fg};
    } forEach _idcs;
};

[[PAC_IDC_MG_BACKGROUND], _base, nil] call _fnc_paint;
[[PAC_IDC_MG_L_BACK, PAC_IDC_MG_R_BACK], _lift, nil] call _fnc_paint;
[[PAC_IDC_MG_SUBTITLE, PAC_IDC_MG_COUNT, PAC_IDC_MG_HINT], nil, _mute] call _fnc_paint;
[[PAC_IDC_MG_ID_LABEL, PAC_IDC_MG_F1_LABEL, PAC_IDC_MG_F2_LABEL, PAC_IDC_MG_F3_LABEL, PAC_IDC_MG_F4_LABEL, PAC_IDC_MG_F5_LABEL, PAC_IDC_MG_F6_LABEL], nil, _inkFull] call _fnc_paint;
[[PAC_IDC_MG_CLOSE, PAC_IDC_MG_NEW, PAC_IDC_MG_SAVE, PAC_IDC_MG_REMOVE, PAC_IDC_MG_EXPORT], _base, _inkFull] call _fnc_paint;
[[PAC_IDC_MG_SECTION, PAC_IDC_MG_FILTER, PAC_IDC_MG_LIST, PAC_IDC_MG_ID, PAC_IDC_MG_F1, PAC_IDC_MG_F2, PAC_IDC_MG_F3, PAC_IDC_MG_F4, PAC_IDC_MG_F5, PAC_IDC_MG_F6], _base, _inkFull] call _fnc_paint;
(_display displayCtrl PAC_IDC_MG_LIST) ctrlSetActiveColor _accentFull;

private _title = _display displayCtrl PAC_IDC_MG_TITLE;
_title ctrlSetStructuredText parseText "<t font='RobotoCondensedBold' size='1.25'>TAC//PAC</t>";
_title ctrlSetTextColor _accentFull;
(_display displayCtrl PAC_IDC_MG_SUBTITLE) ctrlSetStructuredText parseText "<t size='0.8'>M A N A G E   -   the action log, the ORBAT, the operator files</t>";
