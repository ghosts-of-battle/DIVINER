#include "script_component.hpp"
/*
 * Author: Ghost
 * RADIO: the set in your hand and the channel it is on.
 *
 * IT DOES NOT IMPLEMENT A RADIO. EFUNC(tacpad_apps,radioState) asks ACRE or TFAR,
 * whichever the mission is running, and answers a string - so this reads whatever
 * the reader panel reads and cannot disagree with it. With neither mod loaded
 * there is no set and the tile says so, rather than inventing a channel.
 *
 * THE JAMMING IS ON IT because a channel is only worth reading next to whether
 * anyone will hear it. That is the one number from the other tile that belongs
 * here.
 *
 * Arguments:
 * 0: The slot control <CONTROL>
 * 1: Y to start at <NUMBER>
 * 2: Slot width <NUMBER>
 * 3: Slot height <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_ctrl", controlNull, [controlNull]], ["_y", 0, [0]], ["_w", 0, [0]], ["_h", 0, [0]]];

if (isNull _ctrl) exitWith {};

([] call EFUNC(tacpad,theme)) params ["_ground", "_ink", "_accent", "_line"];

private _base = ROW_H * EGVAR(tacpad,textScale) * EGVAR(tacpad,uiScale) * safeZoneH;
// A ROW IS THE SUITE'S OWN ROW, AND IT ONLY EVER SHRINKS. Rows used to be the
// slot's whole box divided by however many of them there were, so a slot at its
// default size - the vanilla Custom Info panel's size - spread three lines down
// the whole panel with holes between them, at type twice the size the rest of
// the suite sets. The design's row height is the row height here too: a slot the
// player has made too SHORT for its rows squeezes them, and one made taller
// simply has air under the readout.
private _rowH = _base min ((_h - _y - (PAD * safeZoneW)) / 3);
// Width caps the scale too - see the note in FUNC(widgetEw).
private _kw = (_w / (10 * (((safeZoneW / safeZoneH) min 1.2) / 40))) max 0.8;
private _k = ((_rowH / _base) min _kw) max 0.8;
private _pad = PAD * safeZoneW;
private _mute = [_ink # 0, _ink # 1, _ink # 2, 0.62];
private _dim = [_ink # 0, _ink # 1, _ink # 2, 0.42];
private _amber = [0.85, 0.65, 0.15, 1];

private _channel = "";
if (!isNil QEFUNC(tacpad_apps,radioState)) then {
    _channel = [] call EFUNC(tacpad_apps,radioState);
};

if (_channel isEqualTo "") exitWith {
    [_ctrl, [_pad, _y, _w - 2 * _pad, _rowH], "NO SET IN HAND", _dim, (0.85 * _k), true] call EFUNC(tacpad,drawText);
};

[_ctrl, [_pad, _y, _w - 2 * _pad, _rowH * 1.4], _channel, _ink, (1.3 * _k), true] call EFUNC(tacpad,drawText);

private _sweep = [] call FUNC(sweep);
if (_sweep isEqualTo []) exitWith {};

_sweep params ["", "", "", ["_jam", 0]];
private _pct = round (_jam * 100);

private _colour = switch (true) do {
    case (_pct >= 50): {_accent};
    case (_pct > 0): {_amber};
    default {_ink};
};

[_ctrl, [_pad, _y + _rowH * 1.6, _w * 0.5, _rowH], "JAM", _mute, (0.62 * _k), true, "left", true] call EFUNC(tacpad,drawText);
[
    _ctrl, [_w * 0.5, _y + _rowH * 1.6, _w * 0.5 - _pad, _rowH],
    format ["%1%2", _pct, "%"], _colour, (0.9 * _k), true, "right"
] call EFUNC(tacpad,drawText);
