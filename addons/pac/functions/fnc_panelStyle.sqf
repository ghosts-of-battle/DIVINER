#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelStyle

Description:
    Paints the admin page from the player's tacpad scheme, the moment it
    opens. The same reasoning as the console's FUNC(style): the colours in the
    dialog config are the dark scheme so nothing flashes, and everything a
    player can actually change lives in the tacpad's settings, which a config
    file cannot read.

    The wordmark is written here rather than in config, because a double slash
    in a CONFIG string is a preprocessor gamble; in SQF it is just text.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(display), displayNull];
if (isNull _display) exitWith {};

([] call EFUNC(tacpad,theme)) params ["_ground", "_ink", "_accent"];

// Settings may not be in yet - a keybind in the first seconds of a mission gets
// here before CBA_settingsInitialized - so the opacity is read through a default.
private _opacity = ((missionNamespace getVariable [QEGVAR(tacpad,opacity), 0.92]) max 0.88) min 1;
private _base = [_ground # 0, _ground # 1, _ground # 2, _opacity];
private _lift = [
    ((_ground # 0) * 0.82) + ((_ink # 0) * 0.18),
    ((_ground # 1) * 0.82) + ((_ink # 1) * 0.18),
    ((_ground # 2) * 0.82) + ((_ink # 2) * 0.18),
    _opacity
];
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

[[PAC_IDC_BACKGROUND], _base, nil] call _fnc_paint;
[[PAC_IDC_L_BACK, PAC_IDC_M_BACK, PAC_IDC_R_BACK], _lift, nil] call _fnc_paint;

// Labels and blocks of text: ink on the rail, the section titles muted.
[[PAC_IDC_SUBTITLE, PAC_IDC_L_TITLE, PAC_IDC_M_TITLE, PAC_IDC_R_TITLE, PAC_IDC_SKILLS_TITLE, PAC_IDC_AWARDS_TITLE, PAC_IDC_NOTES_TITLE, PAC_IDC_ORPHANS_TITLE, PAC_IDC_LOG_TITLE, PAC_IDC_WINDOW_TITLE, PAC_IDC_BACKUP_TITLE, PAC_IDC_TOOLS_TITLE, PAC_IDC_L_COUNT, PAC_IDC_HINT, PAC_IDC_SERVICE_LINE], nil, _mute] call _fnc_paint;
[[PAC_IDC_M_NAME, PAC_IDC_R_STATUS, PAC_IDC_RANK_LABEL, PAC_IDC_ROLE_LABEL, PAC_IDC_STATUS_LABEL, PAC_IDC_GROUP_LABEL, PAC_IDC_ENLISTED_LABEL, PAC_IDC_PROMOTED_LABEL], nil, _inkFull] call _fnc_paint;

// Buttons sit on the ground, ink on them; the accent is for the one that is on.
[[PAC_IDC_CLOSE, PAC_IDC_L_UNASSIGNED, PAC_IDC_AWARD_ADD, PAC_IDC_AWARD_REMOVE, PAC_IDC_NOTE_ADD, PAC_IDC_KICK, PAC_IDC_BAN, PAC_IDC_WINDOW_START, PAC_IDC_WINDOW_STOP, PAC_IDC_REPORT, PAC_IDC_EXPORT, PAC_IDC_IMPORT, PAC_IDC_RESTORE, PAC_IDC_STRUCTURE, PAC_IDC_SAMPLE_ADD, PAC_IDC_SAMPLE_REMOVE, PAC_IDC_STRUCT_OPEN, PAC_IDC_MANAGE_OPEN, PAC_IDC_STRUCT_IMPORT, PAC_IDC_ENLISTED_SET, PAC_IDC_PROMOTED_SET, PAC_IDC_M_SAVE, PAC_IDC_CSV_IMPORT, PAC_IDC_L_ADD], _base, _inkFull] call _fnc_paint;
if (GVAR(panelUnassigned)) then {
    [[PAC_IDC_L_UNASSIGNED], _accentFull, [_ground # 0, _ground # 1, _ground # 2, 1]] call _fnc_paint;
};

// Lists, combos and edits are inset - the ground, not the rail.
[[PAC_IDC_L_LIST, PAC_IDC_SKILLS_LIST, PAC_IDC_AWARDS_LIST, PAC_IDC_NOTES_LIST, PAC_IDC_ORPHANS_LIST, PAC_IDC_LOG_LIST, PAC_IDC_RANK_COMBO, PAC_IDC_GROUP_COMBO, PAC_IDC_ROLE_COMBO, PAC_IDC_STATUS_COMBO, PAC_IDC_AWARD_COMBO, PAC_IDC_L_FILTER, PAC_IDC_NOTE_EDIT, PAC_IDC_WINDOW_NAME, PAC_IDC_ENLISTED, PAC_IDC_PROMOTED], _base, _inkFull] call _fnc_paint;
{
    (_display displayCtrl _x) ctrlSetActiveColor _accentFull;
} forEach [PAC_IDC_L_LIST, PAC_IDC_SKILLS_LIST, PAC_IDC_AWARDS_LIST, PAC_IDC_NOTES_LIST, PAC_IDC_ORPHANS_LIST, PAC_IDC_LOG_LIST];

// The wordmark, in the accent.
private _title = _display displayCtrl PAC_IDC_TITLE;
_title ctrlSetStructuredText parseText "<t font='RobotoCondensedBold' size='1.25'>TAC//PAC</t>";
_title ctrlSetTextColor _accentFull;

(_display displayCtrl PAC_IDC_SUBTITLE) ctrlSetStructuredText parseText "<t size='0.8'>P E R S O N N E L   ·   ranks, roles, skills, awards and notes for the unit's roster</t>";
