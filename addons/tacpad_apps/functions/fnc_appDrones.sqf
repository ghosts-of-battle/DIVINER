#include "script_component.hpp"
/*
 * Author: Ghost
 * DRONES, full size: what is unmanned and hostile in the air, and where.
 * NOTHING ELSE. Drones and jamming are two different things and their pages
 * must not look alike - the user's rule, in those words. Jamming has its own
 * page (FUNC(appJamming)); the whole sweep at once is the EW SCANNER.
 *
 * Every value is EFUNC(hacking,scannerRead)'s cache - the same sweep the tile
 * and the handset read, so no two surfaces can disagree about the air.
 *
 * Arguments (app handler):
 * 0: Map display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

if (isNil QEFUNC(hacking,scannerRead)) exitWith {
    ["DRONES", "The intrusion suite is not loaded.", "high"] call EFUNC(messaging,notify);
};

([_display, "DRONES", 0.36, 0.34] call EFUNC(tacpad,appFrame)) params ["", "_body"];
if (isNull _body) exitWith {};

([] call EFUNC(tacpad,theme)) params ["_ground", "_ink", "_accent", "_line"];

private _rowH = ROW_H * EGVAR(tacpad,textScale) * EGVAR(tacpad,uiScale) * safeZoneH;
private _w = (ctrlPosition _body) # 2;
private _pad = PAD * safeZoneW;
private _padY = PAD * safeZoneH;
private _mute = [_ink # 0, _ink # 1, _ink # 2, 0.62];
private _amber = [0.85, 0.65, 0.15, 1];

if !([player] call EFUNC(hacking,hasScanner)) exitWith {
    [_body, [_pad, _padY, _w - 2 * _pad, _rowH], "NO RECEIVER", _accent, 1.2, true] call EFUNC(tacpad,drawText);
};

([] call EFUNC(hacking,scannerRead)) params
    ["_droneState", "_droneDist", "_droneDir", "", "", "", "", ["_droneTag", ""]];

// What this draw is OF. The loop below stands still while this is unchanged,
// instead of tearing the window down every two seconds - a rebuild is deleted
// buttons, and a button deleted between a press and its release is an eaten
// press. With no contact this page is a still page, so it gets no rebuilds.
uiNamespace setVariable [QGVAR(dronesSeen), str [_droneState, round _droneDist, round _droneDir, _droneTag]];

private _colour = [_ink, _amber, _accent] select (0 max (_droneState min 2));

[
    _body, [_pad, _padY, _w - 2 * _pad, _rowH * 1.6],
    ["NO AIR CONTACT", "CONTACT - INSIDE 2 KM", "CONTACT - INSIDE 1 KM"] select (0 max (_droneState min 2)),
    _colour, 1.5, true
] call EFUNC(tacpad,drawText);

private _y = _padY + _rowH * 1.8;
[_body, [_pad, _y, _w - 2 * _pad, RULE_THICK * pixelH], _ink] call EFUNC(tacpad,drawFill);
_y = _y + _padY;

if (_droneState <= 0) then {
    [_body, [_pad, _y, _w - 2 * _pad, _rowH], "Nothing unmanned and hostile within two kilometres.", _mute, 0.8] call EFUNC(tacpad,drawText);
} else {
    // Bearing zero-padded the handset's way - the column must not jump about
    // as the drone circles.
    private _brg = str round _droneDir;
    while {count _brg < 3} do {_brg = "0" + _brg};

    private _rows = [
        ["BEARING", format ["%1 deg", _brg]],
        ["RANGE", format ["%1 m", round _droneDist]]
    ];
    if (_droneTag isNotEqualTo "") then {_rows pushBack ["AIRFRAME", toUpper _droneTag]};

    {
        _x params ["_label", "_value"];
        private _ry = _y + _forEachIndex * _rowH;
        [_body, [_pad, _ry, _w * 0.4, _rowH], _label, _mute, 0.62, true, "left", true] call EFUNC(tacpad,drawText);
        [_body, [_w * 0.4, _ry, _w * 0.6 - _pad, _rowH], _value, _colour, 0.9, true, "right"] call EFUNC(tacpad,drawText);
        [_body, [_pad, _ry + _rowH - RULE_THIN * pixelH, _w - 2 * _pad, RULE_THIN * pixelH], _line] call EFUNC(tacpad,drawFill);
    } forEach _rows;
};

// Live page, the scanner app's own loop pattern - hold the redraw while the
// pointer is on it, stand down when the app closes.
private _existing = uiNamespace getVariable [QGVAR(dronesPFH), -1];
if (_existing >= 0) then {
    [_existing] call CBA_fnc_removePerFrameHandler;
};

uiNamespace setVariable [QGVAR(dronesPFH), [{
    params ["", "_handle"];

    if !(["drones"] call EFUNC(tacpad,appAlive)) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        uiNamespace setVariable [QGVAR(dronesPFH), -1];
    };

    if !([] call EFUNC(tacpad,appIdle)) exitWith {};

    // Redraw ONLY when the air changed - the same seen-cache rule that
    // stopped TAC//SUPPORT flickering. The key must be built exactly as the
    // draw builds its own.
    private _read = [] call EFUNC(hacking,scannerRead);
    if ((str [_read param [0, 0], round (_read param [1, -1]), round (_read param [2, -1]), _read param [7, ""]]) isEqualTo (uiNamespace getVariable [QGVAR(dronesSeen), ""])) exitWith {};

    ["drones"] call EFUNC(tacpad,openApp);
}, 2, []] call CBA_fnc_addPerFrameHandler];
