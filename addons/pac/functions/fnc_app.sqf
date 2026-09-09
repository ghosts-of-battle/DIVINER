#include "script_component.hpp"
/*
 * Author: YonV
 * TAC//PAC - the unit, as a player sees it. Three views under one tab row:
 * RECORD (their own), ROSTER (everybody), OPORD (the list and the open one).
 *
 * READ-ONLY, ON PURPOSE. Nothing here writes anything. Ranks, skills, awards
 * and status are set by admins through the admin panel, and the roster a client
 * draws is the copy the server published - see FUNC(publish). A player can
 * look at their record and cannot touch it, which is what makes the record
 * worth looking at.
 *
 * AND ANY MAN'S RECORD, from the ROSTER tab: tap a name and the RECORD tab
 * shows his published row. NOT HIS NOTES - FUNC(publish) never sends them,
 * because a note is written by an admin ABOUT a player; they live on the
 * admin page and nowhere else (user, 2026-09-05). The tab row clears whoever
 * was open, so MY RECORD is always your own.
 *
 * THE STRUCTURE IS READ LOCALLY. Every rank, skill and OPORD is compiled config
 * and identical on every machine, so an id is turned into a name here rather
 * than the server sending names down - FUNC(lookup) is that, and it also says
 * when an id points at nothing any more.
 *
 * IT IS DRAWN IN THE SUITE'S OWN HAND. The same appFrame, the same drawText,
 * the same rule weights as every other app, because a unit management screen
 * that looked like a different mod would be read as one.
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

// AN OPEN ORDER GETS A TALLER FRAME. An OPORD is nine blocks of prose, and the
// record's height cut it off after FRIENDLY (user, 2026-09-05: "this is
// missing information and rows").
// NIL-SAFE ON BOTH SIDES, AND NO BRACES. `a && b` evaluates b whatever a is;
// only `a && {b}` short-circuits. The braces this line had were taken off for
// a lint help (L-S26) on 2026-09-05, after which openOpord - unset until an
// order has ever been opened - was read on every open, the draw aborted on
// the undefined variable, and every tab came up blank ("the my record button
// does not work"). getVariable with a default never errors, so this is safe
// without the braces the lint objects to.
private _tall = (missionNamespace getVariable [QGVAR(view), "record"]) isEqualTo "opord"
    && (missionNamespace getVariable [QGVAR(openOpord), ""]) isNotEqualTo "";
([_display, "PAC", 0.62, [0.58, 0.88] select _tall] call ghostD_tacpad_fnc_appFrame) params ["", "_body"];
if (isNull _body) exitWith {};

([] call ghostD_tacpad_fnc_theme) params ["_ground", "_ink", "_accent", "_line"];

private _rowH = ROW_H * ghostD_tacpad_textScale * ghostD_tacpad_uiScale * safeZoneH;
private _pos = ctrlPosition _body;
private _w = _pos # 2;
private _h = _pos # 3;
private _pad = PAD * safeZoneW;
private _padY = PAD * safeZoneH;
private _mute = [_ink # 0, _ink # 1, _ink # 2, 0.62];
private _dim = [_ink # 0, _ink # 1, _ink # 2, 0.42];

private _view = GVAR(view);
private _uid = [player] call FUNC(uid);
private _roster = missionNamespace getVariable [QGVAR(roster), []];

// DIAGNOSTIC (2026-09-05, "the my record button does not work"): every draw
// says which view it drew and whether this player's own row was on the roster,
// so the .rpt answers the question the screen cannot. Hoisted into one string
// - a comma inside a macro argument reads as an argument separator.
private _found = (_roster findIf {(_x # 0) isEqualTo _uid}) >= 0;
private _diag = format ["PAC app drawn: view '%1', %2 on the roster, uid %3, own record %4", _view, count _roster, _uid, ["NOT found", "found"] select _found];
INFO_1("%1",_diag);

// ---- the tab row -------------------------------------------------------------
private _y = 0;
{
    _x params ["_id", "_label"];
    private _tw = _w / 3;
    private _tx = _forEachIndex * _tw;
    private _on = _id isEqualTo _view;

    if (_on) then {
        [_body, [_tx, _y, _tw - _pad, _rowH], [_accent # 0, _accent # 1, _accent # 2, 0.14]] call ghostD_tacpad_fnc_drawFill;
    };
    [_body, [_tx, _y, _tw - _pad, _rowH], ([_line, _accent] select _on), ([RULE_THIN, RULE_THICK] select _on)] call ghostD_tacpad_fnc_drawFrame;
    [_body, [_tx, _y, _tw - _pad, _rowH], _label, ([_mute, _ink] select _on), 0.75, _on, "center", true] call ghostD_tacpad_fnc_drawText;

    private _hit = [_body, [_tx, _y, _tw - _pad, _rowH], {
        params ["_ctrl"];
        GVAR(view) = _ctrl getVariable [QGVAR(tab), "record"];
        // A TAB IS A FRESH START. Pressing MY RECORD while reading somebody
        // else's must show your own, so the tab row clears whoever was open.
        GVAR(viewUid) = "";
        // DIAGNOSTIC (2026-09-05): the press itself, so a tab that does nothing
        // on screen can be told apart from a press that never arrived.
        INFO_1("PAC tab pressed: '%1' - reopening the app",GVAR(view));
        // NEXT FRAME, UNSCHEDULED - the way every other app reopens itself
        // (squad, hack, timer, intel: `{...} call CBA_fnc_execNextFrame`). This
        // was a scheduled `spawn`, the one app in the suite that reopened that
        // way (aligned 2026-09-05 while chasing "the my record button does not
        // work"; not proven to be the cause, but the odd one out is gone).
        {["pac"] call ghostD_tacpad_fnc_openApp} call CBA_fnc_execNextFrame;
    }] call ghostD_tacpad_fnc_drawHit;
    _hit setVariable [QGVAR(tab), _id];
} forEach [["record", "MY RECORD"], ["roster", "ROSTER"], ["opord", "OPORD"]];

_y = _y + _rowH + _padY;
[_body, [0, _y, _w, RULE_THICK * pixelH], _ink] call ghostD_tacpad_fnc_drawFill;
_y = _y + _padY * 2;

// TWO COLUMNS THAT MEET IN THE MIDDLE. The label was pinned to the left edge
// and its value to the right, so a word and its answer sat a whole panel
// apart with nothing between them and the eye had to cross the screen for
// every line. The label is right-aligned against the gutter now and the value
// left-aligned just past it (user, 2026-09-06: "justified right", "justified
// left to make it easier to read").
private _labW = _w * 0.30;
private _valX = _w * 0.34;
private _valW = _w * 0.66 - _pad;

private _fnc_row = {
    params ["_label", "_value", ["_colour", _ink]];
    [_body, [_pad, _y, _labW - _pad, _rowH], _label, _mute, 0.65, true, "right", true] call ghostD_tacpad_fnc_drawText;
    [_body, [_valX, _y, _valW, _rowH], _value, _colour, 0.85, false, "left"] call ghostD_tacpad_fnc_drawText;
    _y = _y + _rowH;
};

// THE SAME ROW WHERE THE VALUE WRAPS, MEASURED RATHER THAN GUESSED. Every
// wrapped block in this app sized itself by counting characters and dividing
// by a guess at how many fit on a line, which is wrong at any text size but
// the one it was tuned on - so the tail of a long block was drawn outside its
// own box and clipped (user, 2026-09-06: "text cut off"). ctrlTextHeight
// reports what the engine actually laid out at this width; the box is grown
// to that and the next row starts below it, so nothing can be cut.
private _fnc_wrapped = {
    params ["_label", "_text", ["_colour", _ink], ["_size", 0.8]];
    if (_label isNotEqualTo "") then {
        [_body, [_pad, _y, _labW - _pad, _rowH], _label, _mute, 0.65, true, "right", true] call ghostD_tacpad_fnc_drawText;
    };
    private _c = [_body, [_valX, _y, _valW, _rowH], _text, _colour, _size, false, "left"] call ghostD_tacpad_fnc_drawText;
    private _th = (ctrlTextHeight _c) max _rowH;
    _c ctrlSetPosition [_valX, _y, _valW, _th];
    _c ctrlCommit 0;
    _y = _y + _th;
};

switch (_view) do {

    // ---- RECORD: your own, or a man tapped on the ROSTER tab ----------------
    // ANOTHER MAN'S RECORD IS THE PUBLISHED ROW AND NOTHING MORE. That row is
    // name, rank, role, group, status, skills, awards and attendance - see
    // FUNC(publish), which deliberately keeps notes and saved loadouts on the
    // server because a note is written by an admin ABOUT a player and is
    // nobody else's business. So this view cannot show a note: the client has
    // never been sent one. Notes stay on the admin page (user, 2026-09-05:
    // "let players click on a name to see their record except notes, notes
    // are for admin in pac only").
    case "record": {
        private _who = [GVAR(viewUid), _uid] select (GVAR(viewUid) isEqualTo "");
        private _self = _who isEqualTo _uid;
        private _me = _roster select {(_x # 0) isEqualTo _who};

        if (_me isEqualTo []) exitWith {
            [_body, [_pad, _y, _w - 2 * _pad, _rowH], "NO RECORD", _dim, 0.8, false] call ghostD_tacpad_fnc_drawText;
            [
                _body, [_pad, _y + _rowH, _w - 2 * _pad, _rowH * 2],
                ["That player is no longer on the published roster.", "The server has not seen you yet, or has not published the roster."] select _self,
                _dim, 0.65, false
            ] call ghostD_tacpad_fnc_drawText;
        };

        // Reading somebody else: a way back to the list, and the roster row is
        // the whole of what there is to read.
        if (!_self) then {
            [_body, [_pad, _y, _w * 0.3, _rowH], "< BACK TO ROSTER", _accent, 0.75, true] call ghostD_tacpad_fnc_drawText;
            [_body, [_pad, _y, _w * 0.3, _rowH], {
                GVAR(viewUid) = "";
                GVAR(view) = "roster";
                {["pac"] call ghostD_tacpad_fnc_openApp} call CBA_fnc_execNextFrame;
            }] call ghostD_tacpad_fnc_drawHit;
            [_body, [_w * 0.3, _y, _w * 0.7 - _pad, _rowH], "PERSONNEL RECORD", _mute, 0.65, true, "right", true] call ghostD_tacpad_fnc_drawText;
            _y = _y + _rowH * 1.2;
        };

        (_me # 0) params ["", "_name", "_rankId", "_roleId", "_groupId", "_statusId", "_skillIds", "_awards", "_updated", ["_time", [0, 0]]];

        private _abbrev = ["ranks", _rankId, "abbrev"] call FUNC(lookup);
        [_body, [_pad, _y, _w - 2 * _pad, _rowH * 1.3], format ["%1 %2", _abbrev, _name], _ink, 1.1, true] call ghostD_tacpad_fnc_drawText;
        _y = _y + _rowH * 1.4;

        ["RANK", ["ranks", _rankId] call FUNC(lookup)] call _fnc_row;
        ["ROLE", ["roles", _roleId] call FUNC(lookup)] call _fnc_row;
        ["GROUP", _groupId] call _fnc_row;
        ["STATUS", ["statuses", _statusId] call FUNC(lookup), _accent] call _fnc_row;
        _y = _y + _padY;

        // ONE WRAPPED LINE EACH, in the value column with everything else -
        // skills were a column a screen tall once (user, 2026-09-05: "line
        // these up horizontally") and awards a second little table of their own.
        if (_skillIds isEqualTo []) then {
            ["SKILLS", "None assigned", _dim] call _fnc_wrapped;
        } else {
            ["SKILLS", (_skillIds apply {["skills", _x] call FUNC(lookup)}) joinString "   ·   "] call _fnc_wrapped;
        };
        _y = _y + _padY;

        if (_awards isEqualTo []) then {
            ["AWARDS", "None", _dim] call _fnc_wrapped;
        } else {
            ["AWARDS", (_awards apply {
                _x params [["_awardId", ""], ["_date", ""]];
                private _n = ["awards", _awardId] call FUNC(lookup);
                [_n, format ["%1  (%2)", _n, _date select [0, 10]]] select (_date isNotEqualTo "")
            }) joinString "   ·   "] call _fnc_wrapped;
        };

        _y = _y + _padY;
        // Attendance, all time - the server totals it from the sessions when it
        // publishes, so the client never sees the sessions themselves. It is on
        // the published row, so it reads the same for a man you tapped.
        _time params [["_mins", 0], ["_joins", 0]];
        ["TIME ON", format ["%1h %2m  ·  %3 session%4", floor (_mins / 60), _mins mod 60, _joins, ["s", ""] select (_joins isEqualTo 1)], _ink] call _fnc_row;
        _y = _y + _rowH * 0.5;

        [_body, [_pad, _y, _w - 2 * _pad, _rowH], format ["UPDATED %1", _updated], _dim, 0.6, false, "right"] call ghostD_tacpad_fnc_drawText;
    };

    // ---- ROSTER: everybody ------------------------------------------------------
    case "roster": {
        if (_roster isEqualTo []) exitWith {
            [_body, [_pad, _y, _w - 2 * _pad, _rowH], "NO ROSTER", _dim, 0.8, false] call ghostD_tacpad_fnc_drawText;
        };

        // Column heads once, then one row a player. Rank abbrev, name, role, and
        // the status in the accent because it is the thing an admin set on
        // purpose and the thing a player looking down the list is checking.
        [_body, [_pad, _y, _w - 2 * _pad, _rowH * 0.8], "TAP A NAME TO READ THAT MAN'S RECORD", _dim, 0.6, true, "left", true] call ghostD_tacpad_fnc_drawText;
        _y = _y + _rowH * 0.8;

        [_body, [_pad, _y, _w * 0.12, _rowH], "RANK", _mute, 0.6, true, "left", true] call ghostD_tacpad_fnc_drawText;
        [_body, [_w * 0.12, _y, _w * 0.38, _rowH], "NAME", _mute, 0.6, true, "left", true] call ghostD_tacpad_fnc_drawText;
        [_body, [_w * 0.50, _y, _w * 0.30, _rowH], "ROLE", _mute, 0.6, true, "left", true] call ghostD_tacpad_fnc_drawText;
        [_body, [_w * 0.80, _y, _w * 0.20 - _pad, _rowH], "STATUS", _mute, 0.6, true, "right", true] call ghostD_tacpad_fnc_drawText;
        _y = _y + _rowH;
        [_body, [_pad, _y, _w - 2 * _pad, RULE_THIN * pixelH], _line] call ghostD_tacpad_fnc_drawFill;
        _y = _y + _padY;

        {
            if (_y > _h - _rowH) exitWith {};
            _x params ["_rUid", "_name", "_rankId", "_roleId", "", "_statusId"];
            private _mine = _rUid isEqualTo _uid;

            [_body, [_pad, _y, _w * 0.12, _rowH], ["ranks", _rankId, "abbrev"] call FUNC(lookup), _mute, 0.75, false] call ghostD_tacpad_fnc_drawText;
            [_body, [_w * 0.12, _y, _w * 0.38, _rowH], _name, _ink, 0.8, _mine] call ghostD_tacpad_fnc_drawText;
            [_body, [_w * 0.50, _y, _w * 0.30, _rowH], ["roles", _roleId] call FUNC(lookup), _mute, 0.75, false] call ghostD_tacpad_fnc_drawText;
            [_body, [_w * 0.80, _y, _w * 0.20 - _pad, _rowH], ["statuses", _statusId] call FUNC(lookup), _accent, 0.7, false, "right"] call ghostD_tacpad_fnc_drawText;

            // The row opens that man's record - the published row, no notes.
            private _rowHit = [_body, [_pad, _y, _w - 2 * _pad, _rowH], {
                params ["_ctrl"];
                GVAR(viewUid) = _ctrl getVariable [QGVAR(rowUid), ""];
                GVAR(view) = "record";
                {["pac"] call ghostD_tacpad_fnc_openApp} call CBA_fnc_execNextFrame;
            }] call ghostD_tacpad_fnc_drawHit;
            _rowHit setVariable [QGVAR(rowUid), _rUid];

            _y = _y + _rowH;
        } forEach _roster;
    };

    // ---- OPORD: the list, or the open one ----------------------------------------
    case "opord": {
        // The mission's orders first, then every one the server has cached that
        // the mission no longer carries - those read dim, and open the same way.
        private _live = GVAR(structure) getOrDefault ["opords", createHashMap];
        private _opords = +_live;
        {
            if !(_x in _opords) then {_opords set [_x, _y]};
        } forEach (missionNamespace getVariable [QGVAR(opordArchive), createHashMap]);
        private _open = GVAR(openOpord);

        if (_open isNotEqualTo "" && {!(_open in _opords)}) then { _open = "" };

        // The list. Newest first by the header date, which is a plain string
        // the mission maker typed - sorted as text, which is right if they wrote
        // dates that sort and wrong if they did not, and the fix is theirs.
        if (_open isEqualTo "") exitWith {
            if (count _opords isEqualTo 0) exitWith {
                [_body, [_pad, _y, _w - 2 * _pad, _rowH], "NO OPORDS", _dim, 0.8, false] call ghostD_tacpad_fnc_drawText;
            };

            private _list = (keys _opords) apply {
                [((_opords get _x) get "header") getOrDefault ["date", ""], _x]
            };
            _list sort false;

            private _current = GVAR(settings) getOrDefault ["currentOpord", ""];

            {
                if (_y > _h - _rowH) exitWith {};
                _x params ["_date", "_id"];
                private _hdr = (_opords get _id) get "header";
                private _isCurrent = _id isEqualTo _current;
                private _isLive = _id in _live;
                private _orderId = _hdr getOrDefault ["id", ""];

                if (_isCurrent) then {
                    [_body, [_pad, _y, _w - 2 * _pad, _rowH], [_accent # 0, _accent # 1, _accent # 2, 0.14]] call ghostD_tacpad_fnc_drawFill;
                };
                [_body, [_pad * 2, _y, _w * 0.6, _rowH], _hdr getOrDefault ["title", _id], ([[_dim, _ink] select _isLive, _accent] select _isCurrent), 0.85, _isCurrent] call ghostD_tacpad_fnc_drawText;
                [_body, [_w * 0.6, _y, _w * 0.4 - _pad * 2, _rowH], ([_orderId, _date] select {_x isNotEqualTo ""}) joinString "  -  ", _mute, 0.7, false, "right"] call ghostD_tacpad_fnc_drawText;

                private _hit = [_body, [_pad, _y, _w - 2 * _pad, _rowH], {
                    params ["_ctrl"];
                    GVAR(openOpord) = _ctrl getVariable [QGVAR(id), ""];
                    // NEXT FRAME, UNSCHEDULED - the way every other app reopens itself
        // (squad, hack, timer, intel: `{...} call CBA_fnc_execNextFrame`). This
        // was a scheduled `spawn`, the one app in the suite that reopened that
        // way (aligned 2026-09-05 while chasing "the my record button does not
        // work"; not proven to be the cause, but the odd one out is gone).
        {["pac"] call ghostD_tacpad_fnc_openApp} call CBA_fnc_execNextFrame;
                }] call ghostD_tacpad_fnc_drawHit;
                _hit setVariable [QGVAR(id), _id];
                _y = _y + _rowH;
            } forEach _list;
        };

        // The open one. One section after another, the way the handoff lays it
        // out - flat, no annexes. BACK is the first row so it is never off the
        // bottom of a long order.
        private _o = _opords get _open;
        private _hdr = _o get "header";

        [_body, [_pad, _y, _w * 0.2, _rowH], "< BACK", _accent, 0.75, true] call ghostD_tacpad_fnc_drawText;
        ([_body, [_pad, _y, _w * 0.2, _rowH], {
            GVAR(openOpord) = "";
            // NEXT FRAME, UNSCHEDULED - the way every other app reopens itself
        // (squad, hack, timer, intel: `{...} call CBA_fnc_execNextFrame`). This
        // was a scheduled `spawn`, the one app in the suite that reopened that
        // way (aligned 2026-09-05 while chasing "the my record button does not
        // work"; not proven to be the cause, but the odd one out is gone).
        {["pac"] call ghostD_tacpad_fnc_openApp} call CBA_fnc_execNextFrame;
        }] call ghostD_tacpad_fnc_drawHit);
        private _headline = [_hdr getOrDefault ["id", ""], "DATED " + (_hdr getOrDefault ["date", ""])] select {_x isNotEqualTo "" && _x isNotEqualTo "DATED "};
        [_body, [_w * 0.2, _y, _w * 0.8 - _pad, _rowH], _headline joinString "  -  ", _ink, 0.95, true, "right"] call ghostD_tacpad_fnc_drawText;
        _y = _y + _rowH;

        [_body, [_pad, _y, _w - 2 * _pad, _rowH * 1.3], _hdr getOrDefault ["title", _open], _ink, 1.1, true] call ghostD_tacpad_fnc_drawText;
        _y = _y + _rowH * 1.4;

        // MEASURED, NOT COUNTED. This sized each block by dividing its length
        // by a guess at characters-per-line, which is wrong at every text size
        // but the one it was tuned on: too small and the block ran off its own
        // box and was clipped mid-sentence (user, 2026-09-06: "text cut off"),
        // too large and the later sections fell off the panel. ctrlTextHeight
        // asks the engine what it actually laid out at this width.
        private _fnc_block = {
            params ["_label", "_text"];
            if (_text isEqualTo "" || {_y > _h - _rowH * 2}) exitWith {};
            [_body, [_pad, _y, _w - 2 * _pad, _rowH], _label, _mute, 0.65, true, "left", true] call ghostD_tacpad_fnc_drawText;
            _y = _y + _rowH;

            private _c = [_body, [_pad * 2, _y, _w - 3 * _pad, _rowH], _text, _ink, 0.75, false] call ghostD_tacpad_fnc_drawText;
            private _th = (ctrlTextHeight _c) max _rowH;
            _c ctrlSetPosition [_pad * 2, _y, _w - 3 * _pad, _th];
            _c ctrlCommit 0;
            _y = _y + _th + _padY;
        };

        private _sit = _o get "situation";
        private _msn = _o get "mission";
        private _adm = _o get "adminLogistics";
        private _cs = _o get "commandSignal";
        private _roe = _o get "roe";

        ["SITUATION", _sit getOrDefault ["overview", ""]] call _fnc_block;
        ["ENEMY", _sit getOrDefault ["enemy", ""]] call _fnc_block;
        ["FRIENDLY", _sit getOrDefault ["friendly", ""]] call _fnc_block;
        ["CIVIL / TERRAIN", _sit getOrDefault ["civilTerrain", ""]] call _fnc_block;
        ["MISSION", _msn getOrDefault ["mission", ""]] call _fnc_block;
        ["EXECUTION", _msn getOrDefault ["execution", ""]] call _fnc_block;
        ["ADMIN", _adm getOrDefault ["admin", ""]] call _fnc_block;
        ["LOGISTICS", _adm getOrDefault ["logistics", ""]] call _fnc_block;
        ["SIGNAL", _cs getOrDefault ["signal", ""]] call _fnc_block;
        ["COMMAND", _cs getOrDefault ["command", ""]] call _fnc_block;
        ["ROE", _roe getOrDefault ["roeText", ""]] call _fnc_block;
    };
};

nil
