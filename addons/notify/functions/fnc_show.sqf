#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_notify_fnc_show

Description:
    Fills the first free slot and fades it in. Internal - callers use
    FUNC(notify), which handles the enabled setting, the display and the queue.

Parameters:
    _display : DISPLAY - the notification layer.
    _title   : STRING
    _text    : STRING
    _colour  : ARRAY - RGBA

Returns:
    NUMBER - slot index used, -1 if the stack was full.

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_display", "_title", "_text", "_colour"];

private _used = GVAR(slots) apply { _x select 0 };
private _slot = -1;
for "_i" from 0 to (SLOT_COUNT - 1) do {
    if !(_i in _used) exitWith { _slot = _i };
};
if (_slot < 0) exitWith { -1 };

private _row = count GVAR(slots);
private _ctrls = [_display, _slot, _row] call FUNC(place);
_ctrls params ["_panel", "_bar", "_txt"];

_bar ctrlSetBackgroundColor _colour;

// HEX, NOT DECIMAL. This was three CBA_fnc_formatNumber calls pasted together,
// which spells a colour in base ten: [0.871, 0.361, 0.188] came out as
// "#2229248" - seven characters, no valid reading - and the engine logged
// "Wrong color format size" for every notification the mod has ever raised
// while quietly falling back to white.
private _hex = _colour call BIS_fnc_colorRGBAtoHTML;

// A title or a body is somebody else's text - a thread subject, a call sign -
// and structured text is markup: one bare < in it and the rest of the line is
// swallowed as a tag. Escaped here because this is where it becomes markup.
private _fnc_safe = {
    params [["_s", "", [""]]];
    _s = _s regexReplace ["&", "&amp;"];
    _s = _s regexReplace ["<", "&lt;"];
    _s regexReplace [">", "&gt;"]
};

// The face, guarded: the setting is a list of font names, but a profile written
// by an older version can hold anything, and a bad font name is drawn as no
// text at all.
private _font = missionNamespace getVariable [QGVAR(font), ""];
if (!(_font isEqualType "") || _font isEqualTo "") then {
    _font = "RobotoCondensed";
};

// Structured text takes its face from the markup, not from ctrlSetFont, so the
// font setting is baked in here. Sizes stay as multipliers of the control's own
// height, which FUNC(place) has already set from the setting.
_txt ctrlSetStructuredText parseText format [
    "<t font='%1' size='1.0' color='%2'>%3</t>%4<t font='%1' size='0.9'>%5</t>",
    _font,
    _hex,
    [_title] call _fnc_safe,
    ["<br/>", ""] select (_text isEqualTo ""),
    [_text] call _fnc_safe
];

{
    _x ctrlSetFade 1;
    _x ctrlCommit 0;
    _x ctrlShow true;
    _x ctrlSetFade 0;
    _x ctrlCommit 0.25;
} forEach _ctrls;

GVAR(slots) pushBack [_slot, CBA_missionTime + GVAR(duration)];

if (GVAR(pfh) < 0) then {
    GVAR(pfh) = [FUNC(tick), TICK_INTERVAL, []] call CBA_fnc_addPerFrameHandler;
};

_slot
