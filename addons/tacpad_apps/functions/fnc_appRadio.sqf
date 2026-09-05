#include "script_component.hpp"
/*
 * Author: Ghost
 * RADIO, full size: your own set at the top, and who else in the section is on
 * what underneath it.
 *
 * THE SECTION LIST IS PUBLISHED, NOT QUERIED. Neither ACRE nor TFAR will tell
 * you what anybody else is tuned to - both answer only for the caller's own
 * radio - so every client puts its channel on its unit and this reads those.
 * See FUNC(radioState) and FUNC(radioPublish). A man whose client has not
 * reported reads as unknown rather than as sharing yours.
 *
 * It is a readout. Retuning is done on the radio, in the radio mod's own
 * interface, where the channel names and the encryption live; a second place to
 * change a frequency is a second place for it to be wrong.
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

private _units = (units group player) select {!isNull _x && {isPlayer _x}};
if (_units isEqualTo []) then {_units = [player]};

private _rowH = ROW_H * EGVAR(tacpad,textScale) * EGVAR(tacpad,uiScale) * safeZoneH;
private _padY = PAD * safeZoneH;
private _heroH = _rowH * 2.6;

private _needed = _padY + _heroH + _padY + RULE_THICK * pixelH + _padY
    + ((1 + count _units) * _rowH) + _padY * 2 + RULE_THICK * pixelH + _rowH + _padY;

// The title bar and borders ride on top of the measured content - the
// missing-inch bug that clipped the weather page's last line, fixed here
// before it is reported here too.
([_display, "RADIO", 0.44, (_needed + HEADER_H * EGVAR(tacpad,textScale) * EGVAR(tacpad,uiScale) * safeZoneH + (RULE_THICK * pixelH) * 3) / safeZoneH] call EFUNC(tacpad,appFrame)) params ["", "_body"];
if (isNull _body) exitWith {};

([] call EFUNC(tacpad,theme)) params ["_ground", "_ink", "_accent", "_line"];

private _pos = ctrlPosition _body;
private _w = _pos # 2;
private _pad = PAD * safeZoneW;
private _mute = [_ink # 0, _ink # 1, _ink # 2, 0.62];
private _dim = [_ink # 0, _ink # 1, _ink # 2, 0.42];

private _mine = [] call FUNC(radioState);
private _none = _mine == "";

// Which mod is answering, said plainly. "NO SET" with no explanation is the
// screen refusing to say whether the radio is missing or the mod is.
private _source = switch (true) do {
    case (!isNil "acre_api_fnc_getCurrentRadio"): {"ACRE"};
    case (!isNil "TFAR_fnc_activeSwRadio"): {"TFAR"};
    default {"NO RADIO MOD"};
};

// ------------------------------------------------------------- the header ---
[_body, [_pad, _padY, _heroH], ICON_RADIO, ([_ink, _dim] select _none)] call EFUNC(tacpad,drawIcon);

private _heroX = _pad * 2 + _heroH * pixelW / pixelH;
[
    _body, [_heroX, _padY, _w - _heroX - _pad, _heroH * 0.62],
    [_mine, "NO SET"] select _none,
    ([_ink, _dim] select _none), 1.9, true
] call EFUNC(tacpad,drawText);

// MESH LIVES HERE NOW, not on the EW scanner page. How many relays you can reach
// is a question about your net, and this is the screen about your net; the
// scanner answers what is in the air and how much of it is being jammed. One
// line, one screen - two copies is how they start disagreeing.
private _mesh = -1;
if (!isNil QEFUNC(hacking,scannerRead) && {[player] call EFUNC(hacking,hasScanner)}) then {
    _mesh = ([] call EFUNC(hacking,scannerRead)) param [6, -1];
};

[
    _body, [_heroX, _padY + _heroH * 0.6, _w - _heroX - _pad, _heroH * 0.4],
    if (_mesh < 0) then {
        format ["SOURCE %1", _source]
    } else {
        format ["SOURCE %1 - %2", _source, ["ISOLATED", format ["MESH %1 RELAY(S)", _mesh]] select (_mesh > 0)]
    },
    ([_mute, _accent] select (_mesh isEqualTo 0)), 0.7, true, "left", true
] call EFUNC(tacpad,drawText);

private _y = _padY + _heroH + _padY;
[_body, [_pad, _y, _w - 2 * _pad, RULE_THICK * pixelH], _ink] call EFUNC(tacpad,drawFill);
_y = _y + _padY;

// -------------------------------------------------------------- the rows ----
[_body, [_pad, _y, _w * 0.5, _rowH], "CALLSIGN", _mute, 0.65, true, "left", true] call EFUNC(tacpad,drawText);
[_body, [_w * 0.5, _y, _w * 0.5 - _pad, _rowH], "CHANNEL", _mute, 0.65, true, "right", true] call EFUNC(tacpad,drawText);
_y = _y + _rowH;

private _matched = 0;
{
    private _unit = _x;
    private _ry = _y + _forEachIndex * _rowH;
    private _self = _unit isEqualTo player;

    private _ch = _unit getVariable [QGVAR(radio), ""];
    private _same = _ch != "" && _ch == _mine;
    if (_same && {!_self}) then {_matched = _matched + 1};

    [
        _body, [_pad, _ry, _w * 0.5, _rowH],
        format ["%1 %2", [rank _unit] call EFUNC(tacpad,rankShort), name _unit],
        _ink, 0.9, _self
    ] call EFUNC(tacpad,drawText);

    // Off your channel is the thing worth seeing on this screen, so that is what
    // the accent marks - not the man, and not you.
    [
        _body, [_w * 0.5, _ry, _w * 0.5 - _pad, _rowH],
        [_ch, "UNKNOWN"] select (_ch == ""),
        switch (true) do {
            case (_ch == ""): {_dim};
            case (_self): {_ink};
            case (_same): {_mute};
            default {_accent};
        },
        0.8, true, "right"
    ] call EFUNC(tacpad,drawText);

    [_body, [_pad, _ry + _rowH - RULE_THIN * pixelH, _w - 2 * _pad, RULE_THIN * pixelH], _line] call EFUNC(tacpad,drawFill);
} forEach _units;

_y = _y + (count _units) * _rowH + _padY;
[_body, [_pad, _y, _w - 2 * _pad, RULE_THICK * pixelH], _ink] call EFUNC(tacpad,drawFill);
_y = _y + _padY;

[
    _body, [_pad, _y, _w - 2 * _pad, _rowH],
    switch (true) do {
        case (_source == "NO RADIO MOD"): {"NO RADIO MOD LOADED - NOTHING TO READ"};
        case (_none): {"NO RADIO IN HAND"};
        default {format ["%1 OF %2 WITH YOU ON THIS CHANNEL", _matched, (count _units) - 1]};
    },
    ([_mute, _accent] select (_none && _source != "NO RADIO MOD")),
    0.7, true, "left", true
] call EFUNC(tacpad,drawText);
