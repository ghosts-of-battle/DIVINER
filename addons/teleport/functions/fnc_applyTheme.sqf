#include "script_component.hpp"
/*
 * Author: YonV
 * Repaints the teleport menu in the TAC//PAC colour scheme.
 *
 * THE DIALOG IS CONFIG AND THE SCHEME IS A RUNTIME SETTING, which is the whole
 * problem: `gui.hpp` can only state one set of colours, and the scheme the
 * player picked lives in a CBA setting that config cannot read. So the colours
 * in `gui.hpp` are a fallback and this repaints over them once the display
 * exists. The title bar was Ghost red on every scheme - the one thing anybody
 * notices - and the buttons were flat black.
 *
 * TACPAD IS NOT A DEPENDENCY and must not become one for a colour: `teleport`
 * requires `ghostD_main`, `ghostD_notify` and CBA, and a server running it
 * without the tablet suite is a server this must still open on. With no
 * `ghostD_tacpad_fnc_theme` the config colours simply stand.
 *
 * Arguments:
 * 0: The dialog's display <DISPLAY>
 *
 * Return Value:
 * Whether the scheme was applied <BOOL>
 *
 * Public: No
 */

params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {false};
if (isNil "ghostD_tacpad_fnc_theme") exitWith {false};

([] call ghostD_tacpad_fnc_theme) params [
    ["_ground", [], [[]]],
    ["_ink", [], [[]]],
    ["_accent", [], [[]]]
];

if (_ground isEqualTo [] || {_ink isEqualTo []} || {_accent isEqualTo []}) exitWith {false};

// The bar carries the accent, and its text takes the GROUND rather than the
// ink - accent on ink is the one pairing in the scheme that is not guaranteed
// to be readable, because both are foreground colours.
private _title = _display displayCtrl IDC_TP_TITLE;
if (!isNull _title) then {
    _title ctrlSetBackgroundColor _accent;
    _title ctrlSetTextColor _ground;
};

private _bg = _display displayCtrl IDC_TP_BG;
if (!isNull _bg) then {_bg ctrlSetBackgroundColor _ground};

// The list stays transparent - BgMain is what it sits on, and giving it its own
// ground would draw a second panel a shade off the first.
private _list = _display displayCtrl IDC_TP_LIST;
if (!isNull _list) then {_list ctrlSetTextColor _ink};

{
    private _btn = _display displayCtrl _x;
    if (isNull _btn) then {continue};
    _btn ctrlSetBackgroundColor _ground;
    _btn ctrlSetTextColor _ink;
} forEach [IDC_TP_OK, IDC_TP_CANCEL];

true
