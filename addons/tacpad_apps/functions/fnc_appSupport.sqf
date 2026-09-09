#include "script_component.hpp"
/*
 * Author: YonV
 * TAC//SUPPORT - what support this man is cleared to call, and a way into it.
 *
 * IT DOES NOT REIMPLEMENT SIMPLEX, and that is the whole design. The old
 * TAC//SUPPORT drew its own tasking screen over ALiVE's combat support: a fire
 * mission builder, a target picker, an asset list and a verdict row, about a
 * thousand lines of it, all of them a second implementation of somebody else's
 * system that could and did disagree with it.
 *
 * Simplex has a request screen already, with a map you draw the mission on. So
 * this is a board: every service, every callsign the player is authorised for,
 * what it is doing and how long until it can do it again - and a press hands
 * off to Simplex's own GUI for that entity. One implementation of tasking, and
 * it is not ours.
 *
 * AUTHORISATION IS SIMPLEX'S TOO. sss_common_fnc_getEntities is asked per
 * service and answers only what THIS unit may use, so a man who is not cleared
 * for the guns does not see the guns. We do not filter and we do not cache: a
 * board that disagreed with the request screen about what you may call would be
 * worse than no board.
 *
 * NO SIMPLEX, NO SCREEN. Guarded on the function rather than on a CfgPatches
 * check, because that is the thing actually being called - and it says so
 * rather than drawing an empty board that looks broken.
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

if (isNil "sss_common_fnc_getEntities") exitWith {
    ["SUPPORT", "Simplex Support Services is not loaded.", "high"] call EFUNC(messaging,notify);
};

([_display, "SUPPORT", 0.62, 0.58] call EFUNC(tacpad,appFrame)) params ["", "_body"];
if (isNull _body) exitWith {};

([] call EFUNC(tacpad,theme)) params ["_ground", "_ink", "_accent", "_line"];

private _rowH = ROW_H * EGVAR(tacpad,textScale) * EGVAR(tacpad,uiScale) * safeZoneH;
private _pos = ctrlPosition _body;
private _w = _pos # 2;
private _pad = PAD * safeZoneW;
private _padY = PAD * safeZoneH;
private _mute = [_ink # 0, _ink # 1, _ink # 2, 0.62];
private _dim = [_ink # 0, _ink # 1, _ink # 2, 0.42];

private _unit = call CBA_fnc_currentUnit;

// THE SERVICES SIMPLEX HAS COMMISSIONED, in its own order. Read off its own
// hashmap rather than a list of our own: a service it gains is a row we get for
// nothing, and a service it drops is a row that stops appearing.
private _services = keys (missionNamespace getVariable ["sss_common_services", createHashMap]);

[_body, [_pad, 0, _w - 2 * _pad, _rowH], "AVAILABLE SUPPORT", _mute, 0.65, true, "left", true] call EFUNC(tacpad,drawText);
[_body, [_pad, _rowH, _w - 2 * _pad, RULE_THICK * pixelH], _ink] call EFUNC(tacpad,drawFill);

private _y = _rowH * 1.4;
private _any = false;

{
    private _service = _x;
    private _entities = [_unit, _service] call sss_common_fnc_getEntities;

    // A service with nothing this man may call is not his business and does not
    // take a row. It is not "none available" - he is simply not on that net.
    if (_entities isNotEqualTo []) then {
        _any = true;

        [_body, [_pad, _y, _w - 2 * _pad, _rowH], _service, _mute, 0.65, true, "left", true] call EFUNC(tacpad,drawText);
        _y = _y + _rowH;

        {
            private _entity = _x;
            private _callsign = _entity getVariable ["sss_callsign", "UNNAMED"];
            private _cooldown = _entity getVariable ["sss_cooldownTimer", 0];
            private _ready = _cooldown <= 0;

            [_body, [_pad, _y, _w - 2 * _pad, _rowH], _line, RULE_THIN] call EFUNC(tacpad,drawFrame);
            [_body, [_pad * 3, _y, _w * 0.5, _rowH], _callsign, ([_ink, _dim] select (!_ready)), 0.85, true] call EFUNC(tacpad,drawText);

            // READY, or the wait. A number of seconds is what Simplex counts in,
            // and a man deciding whether to hold for the guns wants the number.
            [
                _body, [_w * 0.5, _y, _w * 0.5 - _pad * 3, _rowH],
                ([format ["%1 S", round _cooldown], "READY"] select _ready),
                ([_accent, _mute] select _ready),
                0.8, _ready, "right"
            ] call EFUNC(tacpad,drawText);

            // SIMPLEX'S OWN PANEL FOR EVERYTHING BUT CAS. Artillery went to a
            // window of ours (FUNC(supportRequest)) and now opens Simplex's
            // request screen like transport and logistics do (user,
            // 2026-09-05: "arty support call needs to open the simplex
            // panel") - a fire mission is drawn on its map, with its
            // dispersion, its rounds and its own rules about what the guns
            // will take, and a second screen in front of that could only
            // disagree with it. CAS keeps ours for now.
            //
            // The map goes first either way: both are dialogs, and a dialog over
            // the map display is one the map can sit on top of.
            private _hit = [_body, [_pad, _y, _w - 2 * _pad, _rowH], {
                params ["_ctrl"];
                private _e = _ctrl getVariable [ARR_2(QGVAR(entity),objNull)];
                private _s = _ctrl getVariable [ARR_2(QGVAR(service),"")];
                if (isNull _e) exitWith {};

                // openMap false, NOT closeDisplay: force-closing the map
                // display desyncs the engine's map toggle, and the M key then
                // will not reopen it (user, 2026-09-05: "after i used the
                // support i no longer would open the map"). openMap closes it
                // the sanctioned way, so M works after.
                openMap false;

                if (toUpper _s isEqualTo "CAS") then {
                    [ARR_2(_e,_s)] call FUNC(supportRequest);
                } else {
                    [ARR_3(_s,_e,false)] call sss_common_fnc_openGUI;
                };
            }] call EFUNC(tacpad,drawHit);
            _hit setVariable [QGVAR(entity), _entity];
            _hit setVariable [QGVAR(service), _service];

            _y = _y + _rowH;
        } forEach _entities;

        _y = _y + _padY;
    };
} forEach _services;

if (!_any) then {
    [_body, [_pad, _y, _w - 2 * _pad, _rowH], "NOTHING ON CALL", _dim, 0.8, false] call EFUNC(tacpad,drawText);
    [_body, [_pad, _y + _rowH, _w - 2 * _pad, _rowH * 2], "No support is commissioned, or you are not cleared for any of it.", _dim, 0.65, false] call EFUNC(tacpad,drawText);
};

nil
