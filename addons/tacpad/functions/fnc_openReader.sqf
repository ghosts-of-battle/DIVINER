#include "script_component.hpp"
/*
 * Author: Ghost
 * Opens the full-size TAC//MSG reader - the design's option 1a, three panes:
 * nets and roster down the left, the traffic list beside it, the opened thread
 * filling the rest.
 *
 * IT IS A SHELL AND A REDRAW. This creates the display, the root group and the
 * one control that has to be typed into; FUNC(readerDraw) puts everything else
 * on it and is called again whenever the selection changes. Nothing here knows
 * what a thread looks like.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Opened <BOOL>
 *
 * Example:
 * [] call ghostD_tacpad_fnc_openReader
 *
 * Public: Yes
 */

if (!hasInterface) exitWith {false};

if (isNil QEGVAR(messaging,index)) exitWith {
    ["READER", "Messaging is not loaded.", "high"] call EFUNC(messaging,notify);
    false
};

if !(createDialog QGVAR(reader)) exitWith {false};

private _display = uiNamespace getVariable [QGVAR(reader), displayNull];
if (isNull _display) exitWith {false};

([] call FUNC(theme)) params ["_ground", "_ink"];

// The screen, as one group. Everything drawn on it is a child, so a redraw is
// "delete this group's children" rather than a hunt through the display.
// Wider, and the extra belongs to the compose side - asked for in red.
private _w = 0.97 * safeZoneW;
private _h = 0.90 * safeZoneH;

private _root = _display ctrlCreate [QGVAR(panel), IDC_RD_ROOT];
_root ctrlSetPosition [safeZoneX + (safeZoneW - _w) / 2, safeZoneY + (safeZoneH - _h) / 2, _w, _h];
_root ctrlCommit 0;

private _fill = _display ctrlCreate [QGVAR(fill), -1, _root];
_fill ctrlSetPosition [0, 0, _w, _h];
_fill ctrlSetBackgroundColor _ground;
_fill ctrlCommit 0;
_fill ctrlAddEventHandler ["MouseButtonDown", {true}];

[_root, [0, 0, _w, _h], _ink, RULE_THICK] call FUNC(drawFrame);

// ESC closes it, which is what every other full-screen thing in the game does.
_display displayAddEventHandler ["KeyDown", {
    params ["_d", "_key"];
    if (_key == 1) exitWith {_d closeDisplay 0; true};
    false
}];

GVAR(readerThread) = "";
GVAR(readerTab) = "all";
GVAR(readerMarkers) = false;

// A reader opened cold is never mid-message. FUNC(composeOpen) turns compose
// back on after this returns, which is why the order matters.
GVAR(composeOn) = false;
GVAR(composePick) = false;
GVAR(composeToPick) = false;
GVAR(composeMarker) = "";
GVAR(composeValues) = createHashMap;
GVAR(composeGridText) = createHashMap;
GVAR(composeTemplate) = "";
GVAR(composeThread) = "";
GVAR(composeTo) = "";
GVAR(composeCc) = "";
GVAR(composeTags) = "";
GVAR(composeError) = "";

[] call FUNC(readerDraw);

true
