#include "script_component.hpp"
/*
 * Author: YonV
 * Draws the fire mission window's left column, and redraws it whenever the
 * target or the round count changes.
 *
 * REDRAWN WHOLE, NOT PATCHED. Every control on the left is destroyed and made
 * again on each change - the same way the tacpad's own panels work. A window
 * that updates six labels in place has six chances to leave one of them saying
 * something that is no longer true.
 *
 * THE GEOMETRY MATCHES dialog.hpp, which owns the map on the right. Both are
 * literal numbers, and they have to move together.
 *
 * Arguments:
 * 0: The dialog <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

// THE DRAW HELPERS TAKE A CONTROL, NOT A DISPLAY. Passing _display threw
// "expected Control" on every line and drew nothing (found in the rpt,
// 2026-09-05). The backdrop (idc 8962) is the canvas the text hangs on.
private _canvas = _display displayCtrl 8962;

private _entity = _display getVariable [QGVAR(entity), objNull];
if (isNull _entity) exitWith {};

private _service = _display getVariable [QGVAR(service), ""];
private _rounds = _display getVariable [QGVAR(rounds), 4];
private _target = _display getVariable [QGVAR(target), []];

// Everything drawn last time. Kept so a redraw does not stack controls on top
// of the ones it is replacing.
{ ctrlDelete _x } forEach (_display getVariable [QGVAR(drawn), []]);
private _drawn = [];

([] call EFUNC(tacpad,theme)) params ["_ground", "_ink", "_accent", "_line"];

private _opacity = (missionNamespace getVariable ["ghostD_tacpad_opacity", 0.92]) max 0.88;
private _base = [_ground # 0, _ground # 1, _ground # 2, _opacity];
private _mute = [_ink # 0, _ink # 1, _ink # 2, 0.62];
private _dim = [_ink # 0, _ink # 1, _ink # 2, 0.42];

// NOT _x AND _y. forEach owns _x, and the rounds row below reads its column
// origin inside one - the buttons were being laid out from the round count.
private _colX = safeZoneX + 0.18 * safeZoneW;
private _colY = safeZoneY + 0.215 * safeZoneH;
private _colW = 0.32 * safeZoneW;
private _colH = 0.505 * safeZoneH;
private _rowH = ROW_H * EGVAR(tacpad,textScale) * EGVAR(tacpad,uiScale) * safeZoneH;
private _pad = PAD * safeZoneW;
private _padY = PAD * safeZoneH;

private _fnc_keep = { _drawn pushBack _this; _this };

// The ground under both halves, drawn once and wide enough to sit behind the
// map as well, so the window reads as one object.
([_canvas, [_colX - _pad, _colY - _rowH * 2, _colW + 0.335 * safeZoneW + _pad * 2, _colH + _rowH * 3.5], _base] call EFUNC(tacpad,drawFill)) call _fnc_keep;

private _callsign = _entity getVariable ["sss_callsign", "UNNAMED"];

([_canvas, [_colX, _colY - _rowH * 1.6, _colW, _rowH], toUpper _service, _mute, 0.65, true, "left", true] call EFUNC(tacpad,drawText)) call _fnc_keep;
([_canvas, [_colX, _colY - _rowH * 0.8, _colW, _rowH], _callsign, _ink, 1.1, true] call EFUNC(tacpad,drawText)) call _fnc_keep;
([_canvas, [_colX, _colY, _colW, RULE_THICK * pixelH], _ink] call EFUNC(tacpad,drawFill)) call _fnc_keep;

private _cy = _colY + _rowH * 0.6;

// ---- the target ------------------------------------------------------------
([_canvas, [_colX, _cy, _colW, _rowH], "TARGET", _mute, 0.65, true, "left", true] call EFUNC(tacpad,drawText)) call _fnc_keep;
_cy = _cy + _rowH;

private _grid = ["CLICK THE MAP", mapGridPosition _target] select (_target isNotEqualTo []);
([_canvas, [_colX, _cy, _colW, _rowH], _grid, ([_dim, _ink] select (_target isNotEqualTo [])), 1, true] call EFUNC(tacpad,drawText)) call _fnc_keep;
_cy = _cy + _rowH + _padY;

private _isArty = toUpper _service isEqualTo "ARTILLERY";

// ---- the guns, or the aircraft ---------------------------------------------
// EVERY GUN IN THE BATTERY, asked one at a time. canFire answers per vehicle
// because range is per vehicle: a battery half in range is a battery that fires
// with half its tubes, which is worth seeing before the press rather than
// discovering in the impact area.
private _vehicles = (_entity getVariable ["sss_vehicles", []]) select {alive _x};
private _able = [];
private _eta = -1;

// CAS HAS NO canFire AND NEEDS NONE. A strafe run is not refused for range -
// the aircraft flies in from a spawn distance - so the only gate is the
// entity's cooldown, which the board already shows and SEND respects below.
// Treating "one aircraft" as "one gun in range" keeps the rest of this file
// from needing to know which service it is drawing.
if (!_isArty) then {
    _able = [_entity];
};

if (_isArty && {_target isNotEqualTo []}) then {
    private _asl = ATLToASL _target;
    {
        ([_x, _asl, "", true] call sss_artillery_fnc_canFire) params [["_ok", false], ["_t", -1]];
        if (_ok) then {
            _able pushBack _x;
            if (_t > _eta) then { _eta = _t };
        };
    } forEach _vehicles;
};

private _sectionLabel = ["MISSION", "BATTERY"] select _isArty;
([_canvas, [_colX, _cy, _colW, _rowH], _sectionLabel, _mute, 0.65, true, "left", true] call EFUNC(tacpad,drawText)) call _fnc_keep;
_cy = _cy + _rowH;

// WHAT KIND OF CAS THIS IS. Simplex commissions an aircraft as one thing -
// a strafe run or a loiter station - and the entity carries which. The player
// is choosing a point either way; the word is there so they know what will
// arrive.
private _gunLine = if (_isArty) then {
    if (_target isEqualTo []) then {
        format ["%1 GUN%2", count _vehicles, ["", "S"] select (count _vehicles > 1)]
    } else {
        format ["%1 OF %2 IN RANGE", count _able, count _vehicles]
    }
} else {
    switch (toUpper (_entity getVariable ["sss_supportType", ""])) do {
        case "STRAFE": {"STRAFE RUN"};
        case "LOITER": {"LOITER STATION"};
        default {"ON CALL"};
    }
};

([_canvas, [_colX, _cy, _colW * 0.55, _rowH], _gunLine, ([_ink, _accent] select (_target isNotEqualTo [] && {_able isEqualTo []})), 0.9, true] call EFUNC(tacpad,drawText)) call _fnc_keep;

// TIME OF FLIGHT, the longest of the guns that can reach - the mission is not
// complete until the last shell lands.
// Time of flight is a shell's. An aircraft's arrival is Simplex's own estimate,
// announced when the request is accepted rather than guessed at here.
private _etaText = ["-", format ["TOF %1 S", round _eta]] select (_eta >= 0);
if (!_isArty) then { _etaText = "" };
([_canvas, [_colX + _colW * 0.55, _cy, _colW * 0.45, _rowH], _etaText, _mute, 0.9, false, "right"] call EFUNC(tacpad,drawText)) call _fnc_keep;
_cy = _cy + _rowH + _padY;

// ---- rounds, artillery only ------------------------------------------------
if (_isArty) then {
([_canvas, [_colX, _cy, _colW, _rowH], "ROUNDS PER GUN", _mute, 0.65, true, "left", true] call EFUNC(tacpad,drawText)) call _fnc_keep;
_cy = _cy + _rowH;

{
    private _n = _x;
    private _bw = _colW / 6;
    private _bx = (_x + (_forEachIndex * _bw));
    private _on = _n isEqualTo _rounds;

    if (_on) then {
        ([_canvas, [_bx, _cy, _bw - _pad, _rowH], [ARR_4(_accent # 0,_accent # 1,_accent # 2,0.18)]] call EFUNC(tacpad,drawFill)) call _fnc_keep;
    };
    ([_canvas, [_bx, _cy, _bw - _pad, _rowH], ([_line, _accent] select _on), ([RULE_THIN, RULE_THICK] select _on)] call EFUNC(tacpad,drawFrame)) call _fnc_keep;
    ([_canvas, [_bx, _cy, _bw - _pad, _rowH], str _n, ([_mute, _ink] select _on), 0.9, _on, "center"] call EFUNC(tacpad,drawText)) call _fnc_keep;

    private _hit = ([_canvas, [_bx, _cy, _bw - _pad, _rowH], {
        params ["_ctrl"];
        private _dlg = ctrlParent _ctrl;
        _dlg setVariable [QGVAR(rounds), _ctrl getVariable [QGVAR(n), 4]];
        [_dlg] call FUNC(supportRequestDraw);
    }] call EFUNC(tacpad,drawHit)) call _fnc_keep;
    _hit setVariable [QGVAR(n), _n];
} forEach [1, 2, 4, 6, 8, 12];

_cy = _cy + _rowH * 2;
};

// ---- send ------------------------------------------------------------------
// COOLDOWN IS THE OTHER REFUSAL, and it is the only one CAS has. Read live
// rather than off the board, which may have been drawn a minute ago.
private _cooldown = _entity getVariable ["sss_cooldownTimer", 0];

private _ready = _target isNotEqualTo [] && _able isNotEqualTo [] && _cooldown <= 0;

private _label = switch (true) do {
    case (_cooldown > 0): {format ["%1 S", round _cooldown]};
    case (_target isEqualTo []): {"NO TARGET"};
    case (_able isEqualTo []): {"OUT OF RANGE"};
    case (!_isArty): {"SEND"};
    default {format ["SEND - %1 ROUNDS", _rounds * count _able]};
};

if (_ready) then {
    ([_canvas, [_colX, _cy, _colW, _rowH * 1.4], [ARR_4(_accent # 0,_accent # 1,_accent # 2,0.9)]] call EFUNC(tacpad,drawFill)) call _fnc_keep;
};
([_canvas, [_colX, _cy, _colW, _rowH * 1.4], ([_line, _accent] select _ready), RULE_THICK] call EFUNC(tacpad,drawFrame)) call _fnc_keep;
([_canvas, [_colX, _cy, _colW, _rowH * 1.4], _label, ([_dim, _ground] select _ready), 1, true, "center"] call EFUNC(tacpad,drawText)) call _fnc_keep;

if (_ready) then {
    ([_canvas, [_colX, _cy, _colW, _rowH * 1.4], {
        params ["_ctrl"];
        [ctrlParent _ctrl] call FUNC(supportRequestSend);
    }] call EFUNC(tacpad,drawHit)) call _fnc_keep;
};

_cy = _cy + _rowH * 2;

// ---- the way out, and the way to the full planner --------------------------
([_canvas, [_colX, _cy, _colW * 0.48, _rowH * 1.2], _line, RULE_THIN] call EFUNC(tacpad,drawFrame)) call _fnc_keep;
([_canvas, [_colX, _cy, _colW * 0.48, _rowH * 1.2], "CLOSE", _mute, 0.85, true, "center"] call EFUNC(tacpad,drawText)) call _fnc_keep;
([_canvas, [_colX, _cy, _colW * 0.48, _rowH * 1.2], {
    params ["_ctrl"];
    (ctrlParent _ctrl) closeDisplay 2;
}] call EFUNC(tacpad,drawHit)) call _fnc_keep;

// SHEAF, DISPERSION, PLANS, COORDINATION - everything this window deliberately
// does not have. Simplex's own planner, opened on the same entity.
([_canvas, [_colX + _colW * 0.52, _cy, _colW * 0.48, _rowH * 1.2], _line, RULE_THIN] call EFUNC(tacpad,drawFrame)) call _fnc_keep;
([_canvas, [_colX + _colW * 0.52, _cy, _colW * 0.48, _rowH * 1.2], "ADVANCED", _mute, 0.85, true, "center"] call EFUNC(tacpad,drawText)) call _fnc_keep;
([_canvas, [_colX + _colW * 0.52, _cy, _colW * 0.48, _rowH * 1.2], {
    params ["_ctrl"];
    private _dlg = ctrlParent _ctrl;
    private _e = _dlg getVariable [QGVAR(entity), objNull];
    private _s = _dlg getVariable [QGVAR(service), ""];
    _dlg closeDisplay 2;
    [_s, _e, false] call sss_common_fnc_openGUI;
}] call EFUNC(tacpad,drawHit)) call _fnc_keep;

_display setVariable [QGVAR(drawn), _drawn];

nil
