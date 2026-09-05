#include "script_component.hpp"
/*
 * Author: Ghost
 * The template picker, drawn into the compose pane: the deck as cards, two up,
 * with what each one will ask you for.
 *
 * CARDS, NOT A LIST OF NAMES. "CASEVAC" and "CONTACT REPORT" are not choices a
 * player can weigh from the words alone under contact - the card says what it
 * is for and how much of it there is to fill in, which is the whole of the
 * decision.
 *
 * A REPLY IS OFFERED ONLY WHAT THE THREAD WILL TAKE. The list comes off the
 * engine's own legality check, so the picker can never show a report the server
 * would refuse.
 *
 * Arguments:
 * 0: [x, width, top y] of the pane, in the content group's own coordinates <ARRAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_pane", [0, 0, 0], [[]], 3]];

_pane params ["_dx", "_dw", "_top"];

private _display = uiNamespace getVariable [QGVAR(reader), displayNull];
if (isNull _display) exitWith {};

private _root = (_display displayCtrl IDC_RD_ROOT) controlsGroupCtrl IDC_RD_CONTENT;
if (isNull _root) exitWith {};

([] call FUNC(theme)) params ["_ground", "_ink", "_accent", "_line"];

private _h = (ctrlPosition _root) # 3;
private _pad = PAD * safeZoneW;
private _padY = PAD * safeZoneH;
private _rowH = ROW_H * GVAR(textScale) * GVAR(uiScale) * safeZoneH;
private _mute = [_ink # 0, _ink # 1, _ink # 2, 0.62];
private _dim = [_ink # 0, _ink # 1, _ink # 2, 0.42];

private _threadId = GVAR(composeThread);

private _ids = if (_threadId isEqualTo "") then {
    ["root"] call EFUNC(messaging,templateIds)
} else {
    private _cached = (missionNamespace getVariable [QEGVAR(messaging,cache), createHashMap]) getOrDefault [_threadId, []];
    private _status = if (_cached isEqualTo []) then {""} else {(_cached # 0) getOrDefault ["status", ""]};
    ["reply", _status] call EFUNC(messaging,templateIds)
};

// The deck scrolls. It is fifteen cards and counting, and a picker that only
// shows what fits is a picker that hides half the deck.
private _bodyW = _dw - 2 * _pad;
private _bodyH = _h - _top - _padY * 2;

private _body = _display ctrlCreate [QGVAR(body), -1, _root];
_body ctrlSetPosition [_dx + _pad, _top, _bodyW, _bodyH];
_body ctrlSetBackgroundColor [0, 0, 0, 0];
_body ctrlCommit 0;

// The scrollbar owns the right edge of a scrolling group, so the cards stop
// short of it rather than being clipped in half by it.
private _scrollW = 14 * pixelW;
private _colW = (_bodyW - _scrollW - _pad) / 2;
private _cardH = _rowH * 2.7;

// NO PLAIN-MESSAGE CARDS. The plain box is the composer's DEFAULT state -
// asked in red: "is not the default a plain text message window" - so the
// picker offers only the forms. The way back to plain is the REMOVE button,
// which is already there whenever a template is on.
// A TEMPLATE ONLY A LEADER MAY SEND IS NOT OFFERED TO ANYONE ELSE. The server
// refuses it anyway (senderMustBe, FUNC(srvThreadFor)); hiding it here is so a
// rifleman does not fill in a METT-TC and learn at SEND that it was not his.
private _isLeader = (player getVariable ["isLeader", false]) isEqualTo true;
_ids = _ids select {
    ((([_x] call EFUNC(messaging,template)) getOrDefault ["senderMustBe", "any"]) isNotEqualTo "leader") || _isLeader
};
private _cards = (_ids select {_x isNotEqualTo "freetext"}) apply {[_x, [_x] call EFUNC(messaging,template)]};

{
    _x params ["_id", "_t"];

    private _col = _forEachIndex % 2;
    private _cx = _col * (_colW + _pad);
    private _cy = floor (_forEachIndex / 2) * (_cardH + _pad);

    private _on = _id isEqualTo GVAR(composeTemplate);
    private _plain = _id isEqualTo "";
    private _fields = count (_t getOrDefault ["order", []]);
    private _flash = (_t getOrDefault ["priority", "normal"]) isEqualTo "high";

    if (_on) then {
        [_body, [_cx, _cy, _colW, _cardH], [_accent # 0, _accent # 1, _accent # 2, 0.12]] call FUNC(drawFill);
    };
    [_body, [_cx, _cy, _colW, _cardH], ([_line, _accent] select _on), ([RULE_THIN, RULE_THICK] select _on)] call FUNC(drawFrame);

    // The kicker: what the report is called on the net, and whether sending it
    // makes somebody's screen go red.
    [
        _body, [_cx + _pad, _cy + _padY * 0.5, _colW - 2 * _pad, _rowH * 0.7],
        [format ["%1%2", _t getOrDefault ["short", _id], ["", " - FLASH"] select _flash], "FREE TEXT"] select _plain,
        ([_mute, _accent] select _flash), 0.6, true, "left", true
    ] call FUNC(drawText);

    [
        _body, [_cx + _pad, _cy + _rowH * 0.85, _colW - 2 * _pad, _rowH],
        [_t getOrDefault ["title", _id], "PLAIN MESSAGE"] select _plain,
        _ink, 0.95, true
    ] call FUNC(drawText);

    [
        _body, [_cx + _pad, _cy + _rowH * 1.85, _colW - 2 * _pad, _rowH * 0.8],
        if (_plain) then {
            "Type it yourself - no form"
        } else {
            [format ["%1 fields to fill", _fields], "Nothing to fill in - one press"] select (_fields isEqualTo 0)
        },
        _mute, 0.68
    ] call FUNC(drawText);

    private _hit = [_body, [_cx, _cy, _colW, _cardH], {
        params ["_ctrl"];
        GVAR(composeTemplate) = _ctrl getVariable [QGVAR(pick), ""];
        GVAR(composePick) = false;
        GVAR(composeMarker) = "";
        {[] call FUNC(readerDraw)} call CBA_fnc_execNextFrame;
    }] call FUNC(drawHit);
    _hit setVariable [QGVAR(pick), _id];
} forEach _cards;

// Under the cards, never over them: with no legal report the deck is one card
// long - PLAIN MESSAGE - and this says why.
if (_ids isEqualTo []) then {
    [
        _body, [0, _cardH + _pad + _padY, _bodyW - _scrollW, _rowH],
        "NO REPORT CAN BE SENT INTO THIS THREAD", _dim, 0.85
    ] call FUNC(drawText);
};
