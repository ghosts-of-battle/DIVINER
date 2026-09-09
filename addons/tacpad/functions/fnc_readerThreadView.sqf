#include "script_component.hpp"
/*
 * Author: Ghost
 * The reader's right-hand pane: the opened thread. Header, the root report as a
 * filled card, the replies down a spine, and the composer at the foot.
 *
 * THE CARD IS THE FORM, NOT PROSE. A 9-line is nine numbered lines with a label
 * and a value each, and that is how it is drawn - two columns of
 * "number | label | value", off the template's own line definitions. Rendering
 * it as a paragraph is how a report becomes something you have to read twice.
 *
 * QUICK REPLIES ARE THE UNIT'S OWN. The design draws six canned phrases and
 * this draws whichever six the player has set - see the Quick replies setting.
 * An entry that names a reply template sends the template; anything else goes as
 * free text. Neither is drawn when the engine would refuse it, so the row can
 * never offer something the server will not take.
 *
 * Arguments:
 * 0: Thread <HASHMAP>
 * 1: Messages <ARRAY>
 * 2: [x, width] of the pane, in the content group's own coordinates <ARRAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_thread", createHashMap, [createHashMap]], ["_messages", [], [[]]], ["_pane", [0, 0], [[]], 2]];

private _display = uiNamespace getVariable [QGVAR(reader), displayNull];
if (isNull _display) exitWith {};

private _root = (_display displayCtrl IDC_RD_ROOT) controlsGroupCtrl IDC_RD_CONTENT;
if (isNull _root) exitWith {};

_pane params ["_dx", "_dw"];

([] call FUNC(theme)) params ["_ground", "_ink", "_accent", "_line"];

private _h = (ctrlPosition _root) # 3;
private _pad = PAD * safeZoneW;
private _padY = PAD * safeZoneH;
private _rowH = ROW_H * GVAR(textScale) * GVAR(uiScale) * safeZoneH;
private _mute = [_ink # 0, _ink # 1, _ink # 2, 0.62];
private _dim = [_ink # 0, _ink # 1, _ink # 2, 0.42];

private _threadId = _thread getOrDefault ["id", ""];
private _flash = (_thread getOrDefault ["priority", ""]) == "high";

// The engine's states are uppercase and the thread carries a real closed flag -
// comparing the status to lowercase "closed" matched nothing, so every closed
// thread still drew a live ACK and the quick-reply row.
private _closed = (_thread getOrDefault ["closed", false]) isEqualTo true
    || {(_thread getOrDefault ["status", ""]) in ["CLOSED", "ABORTED"]};

// What the server would accept right now, worked out once - the ACK button and
// the quick-reply row are both drawn from this, so neither can offer a reply
// the engine refuses.
private _legal = if (_closed) then {[]} else {
    ["reply", _thread getOrDefault ["status", ""]] call EFUNC(messaging,templateIds)
};

// ---------------------------------------------------------------- header ---
private _y = _padY * 2;

private _chipW = _dw * 0.09;
private _chipH = _rowH * 0.7;
if (_flash) then {
    [_root, [_dx + _pad, _y + _rowH * 0.15, _chipW, _chipH], _accent] call FUNC(drawFill);
    [_root, [_dx + _pad * 2, _y + _rowH * 0.15, _chipW, _chipH], "FLASH", _ground, 0.62, true, "left", true] call FUNC(drawText);
};

// The two actions the design puts on the header. ACK is the loud one because it
// is the only one that changes what anybody else sees.
private _btnH = ([0.8] call FUNC(textH)) + 2 * _padY;
private _btnW = _dw * 0.15;
// The last slot on the header row is CLOSE, drawn by FUNC(readerDraw) for
// every view; ACK, PIN and NOTIFY sit to its left (user, 2026-09-05).
private _ackX = _dx + _dw - 2 * _btnW - 2 * _pad;
private _pinX = _ackX - _btnW - _pad;

private _folX = _pinX - _btnW - _pad;

// THE SUBJECT STOPS WHERE THE BUTTONS START. It was given a flat 0.62 of the
// pane, which a FLASH chip pushed straight under PIN TO MAP - a long subject and
// a button drawn through each other.
private _titleX = _dx + _pad + ([0, _chipW + _pad] select _flash);
[_root, [_titleX, _y, _folX - _titleX - _pad, _rowH * 1.2], _thread getOrDefault ["subject", ""], _ink, 1.25, true] call FUNC(drawText);

// FOLLOW / MUTE - the per-thread override the handoff puts in the thread view.
// It beats the net's own subscription either way and lasts the session, which
// is as long as the thread id means anything. One button, three states:
// NET (the net's level decides) -> FOLLOWING (always rings) -> MUTED (badges;
// FLASH and callouts still break through).
private _over = (missionNamespace getVariable [QEGVAR(messaging,threadFollow), createHashMap]) getOrDefault [_threadId, -1];
private _folLabel = switch (_over) do {
    case 0: {"FOLLOWING"};
    case 1: {"MUTED"};
    default {"NOTIFY: NET"};
};
[_root, [_folX, _y, _btnW, _btnH], _ink, RULE_THICK] call FUNC(drawFrame);
[_root, [_folX + _pad, _y, _btnW - 2 * _pad, _btnH], _folLabel, ([_ink, _accent] select (_over >= 0)), 0.7, true, "center"] call FUNC(drawText);
private _folHit = [_root, [_folX, _y, _btnW, _btnH], {
    params ["_ctrl"];
    private _th = _ctrl getVariable [QGVAR(followThread), ""];
    if (_th == "" || {isNil QEFUNC(messaging,follow)}) exitWith {};

    private _cur = (missionNamespace getVariable [QEGVAR(messaging,threadFollow), createHashMap]) getOrDefault [_th, -1];
    [_th, [0, 1, -1] select (_cur + 1)] call EFUNC(messaging,follow);
    {[] call FUNC(readerDraw)} call CBA_fnc_execNextFrame;
}] call FUNC(drawHit);
_folHit setVariable [QGVAR(followThread), _threadId];

[_root, [_pinX, _y, _btnW, _btnH], _ink, RULE_THICK] call FUNC(drawFrame);
[_root, [_pinX + _pad, _y, _btnW - 2 * _pad, _btnH], "PIN TO MAP", _ink, 0.7, true, "center"] call FUNC(drawText);
[_root, [_pinX, _y, _btnW, _btnH], {
    private _t = ((missionNamespace getVariable [QEGVAR(messaging,cache), createHashMap]) getOrDefault [GVAR(readerThread), []]) param [0, createHashMap];
    private _at = _t getOrDefault ["anchorPos", []];
    if (_at isEqualTo []) exitWith {
        ["READER", "This thread has no grid to pin.", "high"] call EFUNC(messaging,notify);
    };

    private _m = createMarkerLocal [format ["ghost_reader_%1_%2", GVAR(readerThread), diag_frameNo], _at];
    _m setMarkerTypeLocal "mil_objective";
    _m setMarkerColorLocal "ColorRed";
    _m setMarkerTextLocal (_t getOrDefault ["subject", "THREAD"]);
    ["READER", "Pinned to your map.", "normal"] call EFUNC(messaging,notify);
}] call FUNC(drawHit);

// ACK SENDS WHAT THE STATE MACHINE WILL TAKE. It sent 'roger' outright, and
// 'roger' is only legal on an ISSUED task - on anything else the server
// refused it and the button read as broken. Where 'roger' is legal it moves
// the task to RECEIPT; anywhere else the acknowledgement goes as the word
// itself in free text, which is legal on any open thread.
private _ackId = switch (true) do {
    case ("roger" in _legal): {"roger"};
    case ("freetext" in _legal): {"freetext"};
    default {""};
};

[_root, [_ackX, _y, _btnW, _btnH], ([_accent, _line] select (_ackId == ""))] call FUNC(drawFill);
[_root, [_ackX + _pad, _y, _btnW - 2 * _pad, _btnH], ["ACK", "CLOSED"] select _closed, ([_ground, _dim] select (_ackId == "")), 0.8, true, "center"] call FUNC(drawText);
if (_ackId != "") then {
    private _hit = [_root, [_ackX, _y, _btnW, _btnH], {
        params ["_ctrl"];
        private _id = _ctrl getVariable [QGVAR(ackTemplate), ""];
        if (_id == "roger") exitWith {
            ["roger", [], [], GVAR(readerThread)] call EFUNC(messaging,submit);
        };
        private _key = ((["freetext"] call EFUNC(messaging,template)) getOrDefault ["order", []]) param [0, "Text.A"];
        ["freetext", [[_key, "ROGER"]], [], GVAR(readerThread)] call EFUNC(messaging,submit);
    }] call FUNC(drawHit);
    _hit setVariable [QGVAR(ackTemplate), _ackId];
};

_y = _y + _rowH * 1.25;

private _root0 = _messages param [0, createHashMap];
[
    _root, [_dx + _pad, _y, _dw - 2 * _pad, _rowH * 0.8],
    format [
        "THREAD %1 - %2 - OPENED BY %3 - %4 REPLIES",
        _threadId,
        toUpper (_thread getOrDefault ["status", ""]),
        _root0 getOrDefault ["fromCallsign", "?"],
        (count _messages) - 1 max 0
    ],
    _mute, 0.6, true, "left", true
] call FUNC(drawText);

_y = _y + _rowH;
[_root, [_dx + _pad, _y, _dw - 2 * _pad, RULE_THICK * pixelH], _ink] call FUNC(drawFill);
_y = _y + _padY * 2;

// ----------------------------------------------------------- the card ------
private _template = [_root0 getOrDefault ["templateId", ""]] call EFUNC(messaging,template);
private _lines = _template getOrDefault ["lines", []];
private _payload = createHashMapFromArray (_root0 getOrDefault ["payload", []]);

if (_lines isNotEqualTo []) then {
    // ONE COLUMN. The lines split into two before, and the user's rule is
    // plain: line reports read top to bottom, one line per row, never
    // wrapped into columns.
    private _cardW = _dw - 2 * _pad;
    private _cardTop = _y;

    [_root, [_dx + _pad, _y, _cardW, _rowH], _ink] call FUNC(drawFill);
    [
        _root, [_dx + _pad * 2, _y, _dw * 0.6, _rowH],
        format ["TEMPLATE - %1", _template getOrDefault ["title", "REPORT"]],
        _ground, 0.62, true, "left", true
    ] call FUNC(drawText);
    [
        _root, [_dx + _dw * 0.6, _y, _dw * 0.4 - _pad * 2, _rowH],
        format ["%1 - %2", toUpper (_root0 getOrDefault ["fromCallsign", "?"]), [_root0 getOrDefault ["sentTime", 0]] call FUNC(clock)],
        _ground, 0.6, true, "right", true
    ] call FUNC(drawText);

    // A LINE IS AS TALL AS ITS ANSWER. A CASEVAC line is a word; an OPORD
    // section is paragraphs, and at one row per line the paragraphs ran over
    // the rows below them into an unreadable stack. The answer is drawn, its
    // wrapped height measured, and the row grown to fit before the next line
    // is placed. The frame goes on last, once the height is known.
    private _cy = _y + _rowH;
    {
        _x params ["", "", "_lineLabel", "_fields", "_lineIndex"];

        private _cx = _dx + _pad;

        // ONE LABEL COLUMN. The short key (HEADER, SITUATION) and the full
        // title (1. SITUATION) said the same thing twice, and the answer only
        // started at 40% of the card (user, 2026-09-05: "do not need both, use
        // only the opord column; expand left to the line"). The title alone,
        // and the answer from a quarter of the way in.
        [_root, [_cx + _pad, _cy, _cardW * 0.23, _rowH], _lineLabel, _mute, 0.6, true, "left", true] call FUNC(drawText);

        // Every field on the line, joined - a line with three boxes ticked reads
        // as one answer, which is what it is. A grid field holds a position
        // when it came off the map; it is shown as the grid, not the array.
        private _parts = [];
        {
            private _key = _x getOrDefault ["key", ""];
            private _v = _payload getOrDefault [_key, ""];
            if (_v isEqualTo "" || _v isEqualTo false) then {continue};

            if ((_x getOrDefault ["type", ""]) isEqualTo "grid" && {_v isEqualType []} && {count _v >= 2}) then {
                _v = mapGridPosition _v;
            };

            private _prefix = _x getOrDefault ["prefix", ""];
            if (_v isEqualTo true) then {
                _parts pushBack ([_prefix, _x getOrDefault ["hint", ""]] select (_prefix == ""));
            } else {
                _parts pushBack format ["%1%2", _prefix, _v];
            };
        } forEach _fields;

        private _valueX = _cx + _cardW * 0.25;
        private _valueW = _cardW * 0.73 - _pad;
        private _value = [
            _root, [_valueX, _cy, _valueW, _rowH],
            [_parts joinString " - ", "-"] select (_parts isEqualTo []),
            ([_ink, _dim] select (_parts isEqualTo [])), 0.8
        ] call FUNC(drawText);

        private _lineH = _rowH max ((ctrlTextHeight _value) + _rowH * 0.25);
        _value ctrlSetPosition [_valueX, _cy, _valueW, _lineH];
        _value ctrlCommit 0;

        [_root, [_cx, _cy + _lineH - RULE_THIN * pixelH, _cardW, RULE_THIN * pixelH], _line] call FUNC(drawFill);
        _cy = _cy + _lineH;
    } forEach _lines;

    private _cardH = (_cy - _cardTop) + _padY;
    [_root, [_dx + _pad, _cardTop, _cardW, _cardH], _ink, RULE_THICK] call FUNC(drawFrame);

    _y = _cardTop + _cardH + _padY * 2;
};

// --------------------------------------------------------- quick replies ---
// THE ROW IS THE PLAYER'S OWN LIST. It was whichever reply templates happened to
// need no fields, which is a list nobody chose - the design draws six phrases a
// unit actually says, and what those are is a unit decision. The setting is read
// here and nowhere else.
//
// An entry that names a reply template sends that template, so the thread's
// state still moves; anything else goes as free text. Either way a button is
// only drawn when the engine would accept it - a row that offers a reply the
// server refuses is worse than a row with one button on it.
// _legal is computed at the top of this function, beside _closed - the ACK
// button and this row must agree about what the server will take.
private _known = missionNamespace getVariable [QEGVAR(messaging,templateIds), []];

private _quick = [];
{
    private _entry = trim _x;
    if (_entry isEqualTo "") then {continue};

    private _id = toLower _entry;

    if (_id in _legal) then {
        _quick pushBack [_id, toUpper (([_id] call EFUNC(messaging,template)) getOrDefault ["short", _entry])];
        continue;
    };

    // A template that this thread will not take is not offered as a phrase
    // either - "CLOSE" typed into a closed thread must not send the words.
    if (_id in _known) then {continue};

    if ("freetext" in _legal) then {
        _quick pushBack ["", toUpper _entry];
    };
} forEach (GVAR(quickReplies) splitString ",");

private _perRow = 5;
private _quickRows = 1 max ceil ((count _quick) / _perRow);

// ------------------------------------------------------------ the spine ----
// A 2px left rule with the replies hung off it: one thread, read top to bottom.
private _composerH = _rowH + _quickRows * (_btnH + _padY) + 2 * (_btnH + _padY) + _padY;
private _spineTop = _y;

// WHICH SIDE A MESSAGE SITS ON IS WHO SENT IT. Traffic that came IN is set
// right; what this player wrote is set left. A thread read top to bottom is then
// a conversation you can follow without reading a call sign on every line -
// which side it is on already told you.
//
// fromUid, not the call sign: a man can file under HQ SIGNALS or under a group's
// name, and it is still him. The uid is the only thing that cannot be borrowed.
private _myUid = getPlayerUID player;

{
    if (_forEachIndex == 0) then {continue};
    private _msg = _x;
    if (_y + _rowH * 2 > _h - _composerH) exitWith {};

    private _mine = (_msg getOrDefault ["fromUid", ""]) isEqualTo _myUid;
    private _align = ["right", "left"] select _mine;

    // The indent is the other half of the tell. Mine hang off the spine; theirs
    // are pushed away from it, so the two columns are visibly different even
    // where a line is short enough to look centred.
    private _tx = _dx + _pad * 3;
    private _tw = _dw - _pad * 4;
    if (!_mine) then {
        _tx = _dx + _dw * 0.2;
        _tw = _dw * 0.8 - _pad * 2;
    };

    // The call sign and the clock swap ends with the message, so the heading
    // always starts at the same edge as the words under it.
    [
        _root, [_tx, _y, _tw * 0.6, _rowH],
        toUpper (_msg getOrDefault ["fromCallsign", "?"]),
        _ink, 0.85, true, _align
    ] call FUNC(drawText);
    [
        _root, [_tx, _y, _tw, _rowH],
        [_msg getOrDefault ["sentTime", 0]] call FUNC(clock),
        _mute, 0.62, true, ["left", "right"] select _mine
    ] call FUNC(drawText);

    // THE CARD'S SHAPE, NOT A PARAGRAPH - joined with " - " this read as one
    // breathless sentence, called out in red. render emits header/value pairs
    // per filled line; the header rows go muted and small, the answers full.
    private _body = [_msg getOrDefault ["templateId", ""], _msg getOrDefault ["payload", []], false] call EFUNC(messaging,render);
    private _bodyLines = (_body splitString endl) select {_x != ""};

    private _ly = _y + _rowH * 0.85;
    {
        private _isHead = (_forEachIndex mod 2) isEqualTo 0;
        private _rowStep = _rowH * ([0.8, 0.7] select _isHead);
        private _line = [
            _root, [_tx, _ly, _tw, _rowH * 0.8],
            _x, ([_ink, _mute] select _isHead), ([0.8, 0.6] select _isHead), _isHead, _align
        ] call FUNC(drawText);
        // A reply's answer can be a paragraph too - same rule as the card:
        // measure the wrapped text and grow the row to hold it.
        private _lineH = _rowStep max ((ctrlTextHeight _line) + _rowH * 0.1);
        (ctrlPosition _line) params ["_lx", "_lyy", "_lw"];
        _line ctrlSetPosition [_lx, _lyy, _lw, _lineH];
        _line ctrlCommit 0;
        _ly = _ly + _lineH;
    } forEach _bodyLines;

    _y = _ly + _rowH * 0.5;
} forEach _messages;

if (_y > _spineTop) then {
    [_root, [_dx + _pad, _spineTop, RULE_THICK * pixelW, _y - _spineTop], _line] call FUNC(drawFill);
};

// --------------------------------------------------------- the composer ----
private _cy = _h - _composerH;
[_root, [_dx + _pad, _cy - _padY, _dw - 2 * _pad, RULE_THICK * pixelH], _ink] call FUNC(drawFill);

[_root, [_dx + _pad, _cy, _dw * 0.4, _rowH], "QUICK REPLY", _mute, 0.62, true, "left", true] call FUNC(drawText);
_cy = _cy + _rowH;

if (_quick isEqualTo []) then {
    [_root, [_dx + _pad, _cy, _dw - 2 * _pad, _btnH], ["NO QUICK REPLY FITS THIS THREAD", "THREAD CLOSED"] select _closed, _dim, 0.7, true] call FUNC(drawText);
} else {
    private _qw = (_dw - 2 * _pad) / (_perRow min (count _quick));

    {
        _x params ["_id", "_label"];
        private _qx = _dx + _pad + (_forEachIndex % _perRow) * _qw;
        private _qy = _cy + floor (_forEachIndex / _perRow) * (_btnH + _padY);

        [_root, [_qx, _qy, _qw - _pad, _btnH], _ink, RULE_THICK] call FUNC(drawFrame);
        [_root, [_qx + _pad, _qy, _qw - 3 * _pad, _btnH], _label, _ink, 0.7, true, "center"] call FUNC(drawText);

        private _hit = [_root, [_qx, _qy, _qw - _pad, _btnH], {
            params ["_ctrl"];
            private _id = _ctrl getVariable [QGVAR(quickId), ""];

            // A phrase is a free-text reply carrying the words on the button;
            // a template id is the template, so the thread's state still moves.
            if (_id isEqualTo "") then {
                private _key = ((["freetext"] call EFUNC(messaging,template)) getOrDefault ["order", []]) param [0, "Text.A"];
                ["freetext", [[_key, _ctrl getVariable [QGVAR(quickText), ""]]], [], GVAR(readerThread)] call EFUNC(messaging,submit);
            } else {
                [_id, [], [], GVAR(readerThread)] call EFUNC(messaging,submit);
            };
        }] call FUNC(drawHit);
        _hit setVariable [QGVAR(quickId), _id];
        _hit setVariable [QGVAR(quickText), _label];
    } forEach _quick;
};

_cy = _cy + _quickRows * (_btnH + _padY);

// + TEMPLATE turns this pane into the composer, on this thread. It used to close
// the reader and open a window over it, which put the thread being answered
// behind the answer.
private _actW = _dw * 0.17;
[_root, [_dx + _pad, _cy, _actW, _btnH], _ink, RULE_THIN] call FUNC(drawFrame);
[_root, [_dx + _pad * 2, _cy, _actW - 3 * _pad, _btnH], "+ TEMPLATE", _ink, 0.68, true, "center"] call FUNC(drawText);
[_root, [_dx + _pad, _cy, _actW, _btnH], {
    [GVAR(readerThread), "", true] call FUNC(composeOpen);
}] call FUNC(drawHit);

// + GRID, the design's third button: your own grid, into the box, without
// reading it off the map and typing it back in.
private _gridX = _dx + _pad * 2 + _actW;
if ("freetext" in _legal) then {
    [_root, [_gridX, _cy, _actW, _btnH], _ink, RULE_THIN] call FUNC(drawFrame);
    [_root, [_gridX + _pad, _cy, _actW - 3 * _pad, _btnH], "+ GRID", _ink, 0.68, true, "center"] call FUNC(drawText);
    [_root, [_gridX, _cy, _actW, _btnH], {
        private _d = uiNamespace getVariable [QGVAR(reader), displayNull];
        if (isNull _d) exitWith {};

        private _ctrl = _d displayCtrl IDC_RD_INPUT;
        private _text = trim (ctrlText _ctrl);
        _ctrl ctrlSetText trim format ["%1 %2", _text, mapGridPosition getPosATL player];
        ctrlSetFocus _ctrl;
    }] call FUNC(drawHit);
};

// + MARKER is a quick reply like the row above it, except that what it sends is
// a place: the marker's name and its grid, in one press. Half of what gets typed
// into a thread is somebody reading a grid off the map and typing it back in,
// which is where a digit gets dropped - the marker already knows both.
private _markerX = _gridX + _pad + _actW;
private _markerOpen = GVAR(readerMarkers);

if ("freetext" in _legal) then {
    [_root, [_markerX, _cy, _actW, _btnH], ([_ink, _accent] select _markerOpen), ([RULE_THIN, RULE_THICK] select _markerOpen)] call FUNC(drawFrame);
    [_root, [_markerX + _pad, _cy, _actW - 3 * _pad, _btnH], "+ MARKER", ([_ink, _accent] select _markerOpen), 0.68, true, "center"] call FUNC(drawText);
    [_root, [_markerX, _cy, _actW, _btnH], {
        GVAR(readerMarkers) = !GVAR(readerMarkers);
        {[] call FUNC(readerDraw)} call CBA_fnc_execNextFrame;
    }] call FUNC(drawHit);
};

[
    _root, [_dx + _dw * 0.6, _cy, _dw * 0.4 - _pad, _btnH],
    format ["REPLY IN THREAD %1", _threadId], _mute, 0.6, true, "right", true
] call FUNC(drawText);

// THE LIST OPENS UPWARDS, over the thread rather than under the fold: it hangs
// off a button already sitting on the bottom edge of the screen. It is drawn
// last, so it is on top of the replies it covers, and on its own opaque ground -
// a translucent dropdown over a thread is two texts in the same place.
if (_markerOpen && {"freetext" in _legal}) then {
    private _markers = [8] call FUNC(markerGrids);
    private _lineH = _rowH * 0.95;
    private _listW = _dw * 0.5;
    private _listH = _lineH * (1 + (1 max count _markers)) + _padY * 2;
    private _listY = _cy - _listH - _padY;
    private _solid = [_ground # 0, _ground # 1, _ground # 2, 1];

    [_root, [_markerX, _listY, _listW, _listH], _solid] call FUNC(drawFill);
    [_root, [_markerX, _listY, _listW, _listH], _ink, RULE_THICK] call FUNC(drawFrame);

    [
        _root, [_markerX + _pad, _listY + _padY, _listW - 2 * _pad, _lineH],
        "SEND A MARKER", _mute, 0.6, true, "left", true
    ] call FUNC(drawText);

    if (_markers isEqualTo []) then {
        [
            _root, [_markerX + _pad, _listY + _padY + _lineH, _listW - 2 * _pad, _lineH],
            "NO MAP MARKERS", _dim, 0.7
        ] call FUNC(drawText);
    } else {
        {
            _x params ["_label", "_at"];
            private _my = _listY + _padY + _lineH * (1 + _forEachIndex);

            [_root, [_markerX + _pad, _my, _listW * 0.6 - _pad, _lineH], _label, _ink, 0.75] call FUNC(drawText);
            [_root, [_markerX + _listW * 0.6, _my, _listW * 0.4 - _pad, _lineH], mapGridPosition _at, _mute, 0.7, false, "right"] call FUNC(drawText);
            [_root, [_markerX + _pad, _my + _lineH - RULE_THIN * pixelH, _listW - 2 * _pad, RULE_THIN * pixelH], _line] call FUNC(drawFill);

            private _hit = [_root, [_markerX, _my, _listW, _lineH], {
                params ["_ctrl"];
                private _text = _ctrl getVariable [QGVAR(markerLine), ""];
                if (_text isEqualTo "") exitWith {};

                GVAR(readerMarkers) = false;

                private _key = ((["freetext"] call EFUNC(messaging,template)) getOrDefault ["order", []]) param [0, "Text.A"];
                ["freetext", [[_key, _text]], [], GVAR(readerThread)] call EFUNC(messaging,submit);

                {[] call FUNC(readerDraw)} call CBA_fnc_execNextFrame;
            }] call FUNC(drawHit);

            // The name AND the grid, because a call sign nobody else has on
            // their map is not a location.
            _hit setVariable [QGVAR(markerLine), format ["%1 - %2", _label, mapGridPosition _at]];
        } forEach _markers;
    };
};

_cy = _cy + _btnH + _padY;

// The one control that is not drawn. SEND reads it, empties it and submits.
private _sendW = _dw * 0.16;

[_root, [_dx + _pad, _cy, _dw - _sendW - 3 * _pad, _btnH], _line, RULE_THIN] call FUNC(drawFrame);

// MADE LAST, INTO THE GROUP, SO IT SITS ON TOP OF ITS OWN FRAME - see
// FUNC(readerInput) for why it cannot be declared, and why it lives inside
// the content group rather than on the display.
[
    _root,
    [
        _dx + _pad * 2,
        _cy,
        _dw - _sendW - 5 * _pad,
        _btnH
    ],
    _ink,
    !_closed
] call FUNC(readerInput);

private _sendX = _dx + _dw - _sendW - _pad;
[_root, [_sendX, _cy, _sendW, _btnH], ([_accent, _line] select _closed)] call FUNC(drawFill);
[_root, [_sendX + _pad, _cy, _sendW - 2 * _pad, _btnH], "SEND", ([_ground, _dim] select _closed), 0.8, true, "center"] call FUNC(drawText);

if (!_closed) then {
    [_root, [_sendX, _cy, _sendW, _btnH], {
        private _d = uiNamespace getVariable [QGVAR(reader), displayNull];
        if (isNull _d) exitWith {};

        private _ctrl = _d displayCtrl IDC_RD_INPUT;
        private _text = ctrlText _ctrl;
        if (trim _text == "") exitWith {};

        _ctrl ctrlSetText "";
        // The key off the template, not spelled here - renaming the line in the
        // deck must not quietly stop the reply box working.
        private _key = ((["freetext"] call EFUNC(messaging,template)) getOrDefault ["order", []]) param [0, "Text.A"];
        ["freetext", [[_key, _text]], [], GVAR(readerThread)] call EFUNC(messaging,submit);
    }] call FUNC(drawHit);
};
