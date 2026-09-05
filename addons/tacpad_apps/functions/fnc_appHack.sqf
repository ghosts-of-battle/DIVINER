#include "script_component.hpp"
/*
 * Author: Ghost
 * INTRUSION, full size, drawn in the suite's own vocabulary: devices in range
 * down the left, the selected one and what to make it produce down the right.
 *
 * IT DOES NOT REIMPLEMENT THE SUITE. Scanning, selection, ranges, cooldowns,
 * the progress clock and what a completed hack yields are all ghost_hacking's
 * and stay ghost_hacking's - this calls scanDevices, tabletSelectDevice,
 * tabletSelectIntel, tabletAction and tabletAdvance and draws the result. The
 * two pieces that used to be trapped inside the suite's own dialog were lifted
 * out into FUNC(intelOptions) and FUNC(tabletAdvance) so there is still one
 * implementation rather than two that can disagree about how far along you are.
 *
 * It used to close the map and hand off to the suite's own display, which is
 * the one screen in the tacpad that looked like a different mod.
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

if (isNil QEFUNC(hacking,tabletAction)) exitWith {
    ["HACK", "The intrusion suite is not loaded.", "high"] call EFUNC(messaging,notify);
};

// Say why, rather than opening a screen that can do nothing. The gate is the
// mission's ISR flag and ghost deliberately never writes it - see
// ghostD_common_fnc_isISR.
if !([player] call EFUNC(hacking,canHack)) exitWith {
    ["HACK", "You are not cleared to use the intrusion suite.", "high"] call EFUNC(messaging,notify);
};

([_display, "INTRUSION", 0.62, 0.58] call EFUNC(tacpad,appFrame)) params ["", "_body"];
if (isNull _body) exitWith {};

([] call EFUNC(tacpad,theme)) params ["_ground", "_ink", "_accent", "_line"];

private _rowH = ROW_H * EGVAR(tacpad,textScale) * EGVAR(tacpad,uiScale) * safeZoneH;
private _pos = ctrlPosition _body;
private _w = _pos # 2;
private _h = _pos # 3;
private _pad = PAD * safeZoneW;
private _padY = PAD * safeZoneH;
private _mute = [_ink # 0, _ink # 1, _ink # 2, 0.62];
private _dim = [_ink # 0, _ink # 1, _ink # 2, 0.42];

// SCAN BEFORE DRAWING THE FIRST FRAME. The refresh loop below rescans on its
// own cadence, but that is a second away - and an app that opens on NOTHING IN
// RANGE beside a tile saying PRESS TO OPEN has already told the player it is
// broken by the time it corrects itself.
call EFUNC(hacking,tabletAdvance);

private _session = EGVAR(hacking,session);
private _devices = EGVAR(hacking,devices);
private _selected = _session get "device";
private _running = _session get "running";

private _listW = _w * 0.46;
[_body, [_listW, 0, RULE_THICK * pixelW, _h], _ink] call EFUNC(tacpad,drawFill);

// ------------------------------------------------------------- the devices --
[_body, [_pad, 0, _listW - 2 * _pad, _rowH], "DEVICES IN RANGE", _mute, 0.65, true, "left", true] call EFUNC(tacpad,drawText);
[_body, [_pad, _rowH, _listW - 2 * _pad, RULE_THICK * pixelH], _ink] call EFUNC(tacpad,drawFill);

if (_devices isEqualTo []) then {
    [_body, [_pad, _rowH * 1.4, _listW - 2 * _pad, _rowH], "NOTHING IN RANGE", _dim, 0.8, false] call EFUNC(tacpad,drawText);
};

private _cardH = _rowH * 1.6;
{
    _x params ["_obj", "_kind", "_label", "_dist", "_range"];

    private _y = _rowH * 1.3 + _forEachIndex * (_cardH + _padY);
    private _on = _obj isEqualTo _selected;
    private _reach = _dist <= _range;

    if (_on) then {
        [_body, [_pad, _y, _listW - 2 * _pad, _cardH], [_accent # 0, _accent # 1, _accent # 2, 0.14]] call EFUNC(tacpad,drawFill);
    };
    [
        _body, [_pad, _y, _listW - 2 * _pad, _cardH],
        ([_line, _accent] select _on),
        ([RULE_THIN, RULE_THICK] select _on)
    ] call EFUNC(tacpad,drawFrame);

    [_body, [_pad * 2, _y, _listW * 0.6, _cardH * 0.55], _label, ([_ink, _dim] select (!_reach)), 0.85, true] call EFUNC(tacpad,drawText);
    [_body, [_pad * 2, _y + _cardH * 0.5, _listW * 0.6, _cardH * 0.5], toUpper _kind, _mute, 0.6, true, "left", true] call EFUNC(tacpad,drawText);

    // Out of range is the one thing that stops a press working, so it is the one
    // thing the card says in the accent.
    [
        _body, [_listW * 0.6, _y, _listW * 0.4 - _pad * 2, _cardH],
        format ["%1 M", round _dist],
        ([_accent, _mute] select _reach),
        0.85, true, "right"
    ] call EFUNC(tacpad,drawText);

    // A running hack owns the selection - changing device mid-hack is what
    // tabletSelectDevice already refuses, so the card does not offer it either.
    if (_running) then {continue};

    private _hit = [_body, [_pad, _y, _listW - 2 * _pad, _cardH], {
        params ["_ctrl"];
        [_ctrl getVariable [QGVAR(slot), -1]] call EFUNC(hacking,tabletSelectDevice);
        {["hack"] call EFUNC(tacpad,openApp)} call CBA_fnc_execNextFrame;
    }] call EFUNC(tacpad,drawHit);
    _hit setVariable [QGVAR(slot), _forEachIndex];
} forEach _devices;

// ---------------------------------------------------------------- the rail --
private _rx = _listW + RULE_THICK * pixelW + _pad * 2;
private _rw = _w - _rx - _pad * 2;
private _ry = 0;

[_body, [_rx, _ry, _rw, _rowH], "TARGET", _mute, 0.65, true, "left", true] call EFUNC(tacpad,drawText);
_ry = _ry + _rowH;

private _label = "NONE SELECTED";
{
    if ((_x # 0) isEqualTo _selected) then {_label = _x # 2};
} forEach _devices;

[_body, [_rx, _ry, _rw, _rowH], _label, ([_ink, _dim] select (isNull _selected)), 1, true] call EFUNC(tacpad,drawText);
_ry = _ry + _rowH + _padY;
[_body, [_rx, _ry, _rw, RULE_THIN * pixelH], _line] call EFUNC(tacpad,drawFill);
_ry = _ry + _padY;

// ----------------------------------------------------------------- product --
[_body, [_rx, _ry, _rw, _rowH], "PRODUCT", _mute, 0.65, true, "left", true] call EFUNC(tacpad,drawText);
_ry = _ry + _rowH;

private _avail = [_session] call EFUNC(hacking,intelOptions);
private _intel = _session get "intel";
private _segH = ([0.7] call EFUNC(tacpad,textH)) + 1.4 * _padY;

if (_avail isEqualTo []) then {
    [_body, [_rx, _ry, _rw, _rowH], "NOTHING TO LOOK FOR", _dim, 0.75, false] call EFUNC(tacpad,drawText);
    _ry = _ry + _rowH;
} else {
    {
        _x params ["_id", "_text"];
        private _on = _id isEqualTo _intel;

        if (_on) then {
            [_body, [_rx, _ry, _rw, _segH], _ink] call EFUNC(tacpad,drawFill);
        } else {
            [_body, [_rx, _ry, _rw, _segH], _line, RULE_THIN] call EFUNC(tacpad,drawFrame);
        };
        [_body, [_rx + _pad, _ry, _rw - 2 * _pad, _segH], _text, ([_ink, _ground] select _on), 0.7, true, "left", true] call EFUNC(tacpad,drawText);

        if (!_running) then {
            private _hit = [_body, [_rx, _ry, _rw, _segH], {
                params ["_ctrl"];
                [_ctrl getVariable [QGVAR(slot), -1]] call EFUNC(hacking,tabletSelectIntel);
                {["hack"] call EFUNC(tacpad,openApp)} call CBA_fnc_execNextFrame;
            }] call EFUNC(tacpad,drawHit);
            _hit setVariable [QGVAR(slot), _forEachIndex];
        };

        _ry = _ry + _segH + _padY * 0.6;
    } forEach _avail;
};

// ---------------------------------------------------------------- progress --
private _btnH = ([0.85] call EFUNC(tacpad,textH)) + 2 * _padY;
private _btnY = _h - _btnH - _padY;
private _barY = _btnY - _rowH - _padY;

private _progress = _session get "progress";
[_body, [_rx, _barY, _rw, _rowH * 0.5], _line] call EFUNC(tacpad,drawFill);
if (_progress > 0) then {
    [_body, [_rx, _barY, _rw * _progress, _rowH * 0.5], _accent] call EFUNC(tacpad,drawFill);
};
[
    _body, [_rx, _barY - _rowH * 0.75, _rw, _rowH * 0.75],
    if (_running) then {format ["WORKING - %1%2", round (_progress * 100), "%"]} else {"STANDING BY"},
    ([_mute, _accent] select _running),
    0.65, true, "left", true
] call EFUNC(tacpad,drawText);

// The one action. It is the suite's own, so a cooldown, a spent tower or being
// out of range all refuse in the suite's words rather than in this screen's.
private _canGo = !isNull _selected;
[_body, [_rx, _btnY, _rw, _btnH], ([_accent, _line] select (!_canGo))] call EFUNC(tacpad,drawFill);
[
    _body, [_rx + _pad, _btnY, _rw - 2 * _pad, _btnH],
    ["BEGIN INTRUSION", "ABORT"] select _running,
    ([_ground, _dim] select (!_canGo)),
    0.85, true, "center"
] call EFUNC(tacpad,drawText);

if (_canGo) then {
    [_body, [_rx, _btnY, _rw, _btnH], {
        call EFUNC(hacking,tabletAction);
        {["hack"] call EFUNC(tacpad,openApp)} call CBA_fnc_execNextFrame;
    }] call EFUNC(tacpad,drawHit);
};

// A hack runs on a clock, so the screen has to keep up with it. The handler goes
// with the app: it stops itself the moment the app group is gone, which is what
// closing it, opening another or shutting the map all amount to.
private _existing = uiNamespace getVariable [QGVAR(hackPFH), -1];
if (_existing >= 0) then {
    [_existing] call CBA_fnc_removePerFrameHandler;
};

uiNamespace setVariable [QGVAR(hackPFH), [{
    params ["", "_handle"];

    // TWO QUESTIONS, NOT ONE. "Is this app still open" decides whether the loop
    // lives; "is the pointer off it" decides whether it may REDRAW. They were
    // the same test, and redrawing means deleting and rebuilding every control
    // on the screen - so this loop was destroying the buttons under the
    // player's cursor once a second and a press had to survive a coin toss.
    // See EFUNC(tacpad,appIdle).
    if !(["hack"] call EFUNC(tacpad,appAlive)) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        uiNamespace setVariable [QGVAR(hackPFH), -1];
    };

    // The hack advances whether or not the screen is being redrawn - the clock
    // is the mission's, not the display's.
    call EFUNC(hacking,tabletAdvance);

    if !([] call EFUNC(tacpad,appIdle)) exitWith {};
    ["hack"] call EFUNC(tacpad,openApp);
}, 1, []] call CBA_fnc_addPerFrameHandler];
