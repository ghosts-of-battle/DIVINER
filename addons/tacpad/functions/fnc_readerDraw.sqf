#include "script_component.hpp"
/*
 * Author: Ghost
 * Draws the reader: nets and roster rail, traffic list, opened thread. Called
 * once on open and again on every selection, so it is the whole screen every
 * time rather than a set of partial updates that can disagree.
 *
 * THE TEMPLATE CARD IS THE REPORT, NOT A PARAGRAPH OF IT. A submitted template
 * renders as the filled form it was sent as - line number, line label, value -
 * because that is what makes a 9-line readable at a glance and prose does not.
 * The lines come off the template's own definition, so a template added to
 * templates.inc.sqf renders here for free.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _display = uiNamespace getVariable [QGVAR(reader), displayNull];
if (isNull _display) exitWith {};

private _shell = _display displayCtrl IDC_RD_ROOT;
if (isNull _shell) exitWith {};

// THE CONTENT IS ITS OWN GROUP, thrown away whole and rebuilt. Deleting "every
// child except the first five" is the same positional addressing that already
// bit the panel frame once; a group has an idc and no opinion about creation
// order.
private _old = _shell controlsGroupCtrl IDC_RD_CONTENT;
if (!isNull _old) then {ctrlDelete _old};

([] call FUNC(theme)) params ["_ground", "_ink", "_accent", "_line"];

private _pos = ctrlPosition _shell;
private _w = _pos # 2;
private _h = _pos # 3;
private _pad = PAD * safeZoneW;
private _padY = PAD * safeZoneH;
private _rowH = ROW_H * GVAR(textScale) * GVAR(uiScale) * safeZoneH;
private _mute = [_ink # 0, _ink # 1, _ink # 2, 0.62];
private _dim = [_ink # 0, _ink # 1, _ink # 2, 0.42];

private _content = _display ctrlCreate [QGVAR(panel), IDC_RD_CONTENT, _shell];
_content ctrlSetPosition [0, 0, _w, _h];
_content ctrlCommit 0;

// Everything below draws into the content group rather than the shell, so the
// frame and the ground survive a redraw untouched.
private _root = _content;

private _railW = _w * 0.17;
private _listW = _w * 0.27;
private _detailX = _railW + _listW + RULE_THICK * pixelW * 2;
private _detailW = _w - _detailX - _pad;

[_root, [_railW, 0, RULE_THICK * pixelW, _h], _ink] call FUNC(drawFill);
[_root, [_railW + _listW + RULE_THICK * pixelW, 0, RULE_THICK * pixelW, _h], _ink] call FUNC(drawFill);

// CLOSE, top-right of the window, on every view (user, 2026-09-05: "put a
// close button in the upper right of the messaging window"). The views leave
// this slot free: the thread header's NOTIFY / PIN / ACK, the composer's
// CANCEL and the net title all stop one slot short of the pane's edge.
// Outlined, not filled - ACK keeps the one loud button. Esc still closes as
// well (FUNC(openReader)).
//
// DRAWN LAST, AFTER THE VIEW - see FUNC(drawHit): a label drawn across a
// button's rectangle AFTER the button is a hole in it. The first version
// drew this before the views, and the full-width lines every view lays under
// its header ran across the button's foot; it showed and did nothing
// ("close button does not work"). So it is a block, called at the end of
// each branch below, and the hit is the last control in the pane.
private _fnc_closeButton = {
    private _closeH = ([0.8] call FUNC(textH)) + 2 * _padY;
    private _closeW = _detailW * 0.15;
    private _closeX = _detailX + _detailW - _closeW - _pad;
    private _closeY = _padY * 2;
    [_root, [_closeX, _closeY, _closeW, _closeH], _ink, RULE_THICK] call FUNC(drawFrame);
    [_root, [_closeX + _pad, _closeY, _closeW - 2 * _pad, _closeH], "CLOSE", _ink, 0.8, true, "center"] call FUNC(drawText);
    [_root, [_closeX, _closeY, _closeW, _closeH], {
        private _d = uiNamespace getVariable [QGVAR(reader), displayNull];
        if (!isNull _d) then {_d closeDisplay 0};
    }] call FUNC(drawHit);
};

private _index = EGVAR(messaging,index);

// ================================================================ the rail ==
private _y = _padY * 2;
[_root, [_pad, _y, _railW - 2 * _pad, _rowH * 1.2], "TAC//MSG", _ink, 1.3, true] call FUNC(drawText);
_y = _y + _rowH * 1.2;
[_root, [_pad, _y, _railW - 2 * _pad, _rowH * 0.8], groupId (group player), _mute, 0.62, true, "left", true] call FUNC(drawText);
_y = _y + _rowH;

[_root, [0, _y, _railW, RULE_THICK * pixelH], _ink] call FUNC(drawFill);
_y = _y + _padY * 2;

[_root, [_pad, _y, _railW - 2 * _pad, _rowH], "NETS", _mute, 0.62, true, "left", true] call FUNC(drawText);
_y = _y + _rowH;

// Kept for the legacy SQUAD key, which older state may still hold.
private _squadBox = format ["G:%1", groupId (group player)];

// WHAT THIS MAN MAY SEE, AND NOTHING ELSE (user, 2026-09-03). The rail used to
// append every declared squad's net for everybody - fifteen rows of other
// people's traffic he cannot open - and read the named nets off the ADDON
// SETTING rather than the mission's GHOSTFR_Nets, so the role gate never reached
// it. Both are FUNC(railNets)'s job now, and the panel reader and the compose
// target list ask the same function the same question.
private _nets = +([player] call EFUNC(messaging,railNets));

// A box the index knows about that nothing declared still gets a row, so a
// mission that files somewhere unusual is not hidden. This cannot leak another
// squad's net back in: the server only indexes what it would deliver, and it
// gates that with FUNC(srvBoxesFor).
{
    if !(_x isEqualType createHashMap) then {continue};
    private _box = _x getOrDefault ["boxId", ""];
    if (_box isEqualType "" && {(_box select [0, 2]) == "B:"}) then {
        _nets pushBackUnique (_box select [2]);
    };
} forEach _index;

_nets pushBack "ALL";

{
    private _net = _x;
    private _on = _net == GVAR(readerNet);
    private _ny = _y + _forEachIndex * _rowH;

    private _unread = 0;
    {
        if (_x isEqualType createHashMap) then {
            if (_net == "ALL"
                || {(_x getOrDefault ["boxId", ""]) in [format ["B:%1", _net], format ["G:%1", _net]]}
                || {_net == "SQUAD" && {(_x getOrDefault ["boxId", ""]) == _squadBox}}) then {
                _unread = _unread + (_x getOrDefault ["unread", 0]);
            };
        };
    } forEach _index;

    if (_on) then {
        [_root, [0, _ny, _railW, _rowH], _accent] call FUNC(drawFill);
    };

    // The design's three-letter net code, then the name. Ours are named by the
    // mission, so the code is the first three letters of whatever it called it -
    // and a net whose name is already three letters or fewer prints once. It
    // printed twice: HQ read "HQ HQ" and ALL read "ALL ALL".
    private _code = toUpper (_net select [0, 3]);
    if (_code isNotEqualTo toUpper _net) then {
        [_root, [_pad, _ny, _railW * 0.28, _rowH], _code, ([_mute, _ground] select _on), 0.62, true, "left", true] call FUNC(drawText);
    };
    [_root, [_pad + _railW * 0.28, _ny, _railW * 0.5, _rowH], _net, ([_ink, _ground] select _on), 0.85, _on] call FUNC(drawText);

    if (_unread > 0) then {
        [_root, [_railW * 0.78, _ny, _railW * 0.22 - _pad, _rowH], str _unread, ([_accent, _ground] select _on), 0.75, true, "right"] call FUNC(drawText);
    };

    // THE RAIL IS THE ADDRESSEE SELECTOR WHILE A MESSAGE IS OPEN. It is already
    // the list of nets with the current one lit, so the compose pane does not
    // carry a chip grid of its own any more - see FUNC(composePane).
    //
    // HARVEST FIRST. The redraw below throws the whole content group away, edits
    // and all, and losing a half-written report to a change of net is not a trade
    // anybody agreed to.
    //
    // A REPLY DOES NOT RETARGET. Addressees belong to the thread the moment one
    // exists - FUNC(composeSend) discards them outright on a reply - so a press
    // here must not pretend otherwise, and it leaves the replied-to thread
    // selected in the list rather than deselecting the conversation being
    // answered.
    private _hit = [_root, [0, _ny, _railW, _rowH], {
        params ["_ctrl"];
        private _pressed = _ctrl getVariable [QGVAR(net), "ALL"];

        if (GVAR(composeOn)) then {
            [] call FUNC(composeHarvest);
            if (GVAR(composeThread) isEqualTo "") then {
                GVAR(composeTo) = [_pressed, true] call FUNC(netBox);

                // AND IT CLOSES THE PICKER, because the picker behind CHANGE asks
                // this exact question. Left up, the redraw put the player straight
                // back onto a list they had just answered off the rail, with the
                // TO line changing behind it.
                GVAR(composeToPick) = false;
            };
        } else {
            GVAR(readerThread) = "";
        };

        GVAR(readerNet) = _pressed;
        {[] call FUNC(readerDraw)} call CBA_fnc_execNextFrame;
    }] call FUNC(drawHit);
    _hit setVariable [QGVAR(net), _net];
} forEach _nets;

_y = _y + (count _nets) * _rowH + _padY;
[_root, [0, _y, _railW, RULE_THICK * pixelH], _ink] call FUNC(drawFill);
_y = _y + _padY * 2;

// ON NET. EVERY PLAYER, UNDER THEIR OWN SQUAD - not just the men in your
// own group. Who is actually on the net is the other half of knowing what
// to send, and "my group only" answered a smaller question than the one
// being asked: a JFO wants to see the platoon, not his own three mates.
//
// Each squad is a head with a count and its men under it. YOUR OWN SQUAD
// IS OPEN and everybody else's is too by default - the user's call - and a
// press on a head folds that one away. The fold is remembered per squad in
// GVAR(readerNetFold), so a rail with six squads on it can be cut down to
// the two anybody cares about and stay that way.
private _fold = uiNamespace getVariable [QGVAR(readerNetFold), []];
private _mySquad = groupId (group player);

// Grouped by call sign, own squad first, the rest alphabetical - a list
// that reorders itself as men die is a list nobody can point at.
private _bySquad = createHashMap;
{
    private _sq = groupId (group _x);
    (_bySquad getOrDefault [_sq, [], true]) pushBack _x;
} forEach (allPlayers select {!isNull _x});

private _order = (keys _bySquad) - [_mySquad];
_order sort true;
if (_mySquad in keys _bySquad) then {_order = [_mySquad] + _order};

[_root, [_pad, _y, _railW - 2 * _pad, _rowH], format ["ON NET - %1", count allPlayers], _mute, 0.62, true, "left", true] call FUNC(drawText);
_y = _y + _rowH;

{
    private _sq = _x;
    private _men = _bySquad getOrDefault [_sq, []];
    private _open = !(_sq in _fold);
    private _up = {alive _x} count _men;

    // The head: the fold arrow, the call sign, and how many of them are
    // still up. Own squad in full ink, everyone else muted - so your own
    // men read first without the list playing favourites with order.
    [_root, [_pad, _y, _railW * 0.12, _rowH * 0.9], (["+", "-"] select _open), _mute, 0.7, true] call FUNC(drawText);
    [
        _root, [_pad + _railW * 0.12, _y, _railW * 0.6, _rowH * 0.9], toUpper _sq,
        ([_mute, _ink] select (_sq isEqualTo _mySquad)), 0.68, true, "left", true
    ] call FUNC(drawText);
    [
        _root, [_railW * 0.72, _y, _railW * 0.28 - _pad, _rowH * 0.9],
        format ["%1/%2", _up, count _men], _mute, 0.6, true, "right", true
    ] call FUNC(drawText);

    private _hit = [_root, [0, _y, _railW, _rowH * 0.9], {
        params ["_ctrl"];
        private _sq = _ctrl getVariable [QGVAR(squad), ""];
        private _fold = uiNamespace getVariable [QGVAR(readerNetFold), []];
        if (_sq in _fold) then {_fold = _fold - [_sq]} else {_fold pushBack _sq};
        uiNamespace setVariable [QGVAR(readerNetFold), _fold];
        {[] call FUNC(readerDraw)} call CBA_fnc_execNextFrame;
    }] call FUNC(drawHit);
    _hit setVariable [QGVAR(squad), _sq];

    _y = _y + _rowH * 0.9;

    if (_open) then {
        {
            private _markH = 7 * pixelH;
            [_root, [_pad * 2, _y + (_rowH * 0.9 - _markH) * 0.5, 7 * pixelW, _markH], ([_dim, _ink] select (alive _x))] call FUNC(drawFill);
            [_root, [_pad * 3 + 7 * pixelW, _y, _railW * 0.58, _rowH * 0.9], name _x, ([_dim, _ink] select (alive _x)), 0.8] call FUNC(drawText);
            [_root, [_railW * 0.62, _y, _railW * 0.38 - _pad, _rowH * 0.9], [_x] call FUNC(roleShort), _mute, 0.6, true, "right", true] call FUNC(drawText);
            _y = _y + _rowH * 0.9;
        } forEach _men;
    };
} forEach _order;

// The self block, pinned to the foot of the rail.
private _selfY = _h - _rowH * 1.6;
[_root, [0, _selfY - _padY, _railW, RULE_THICK * pixelH], _ink] call FUNC(drawFill);
[_root, [_pad, _selfY, _railW - 2 * _pad, _rowH * 0.8], format ["%1 %2", [rank player] call FUNC(rankShort), name player], _ink, 0.85, true] call FUNC(drawText);
[_root, [_pad, _selfY + _rowH * 0.75, _railW - 2 * _pad, _rowH * 0.7], format ["%1 - %2", [player] call FUNC(roleShort), groupId (group player)], _mute, 0.6, true, "left", true] call FUNC(drawText);

// ================================================================ the list ==
private _lx = _railW + RULE_THICK * pixelW;
private _ly = _padY * 2;

private _btnH = ([0.85] call FUNC(textH)) + 2 * _padY;
private _newW = _listW * 0.28;

[_root, [_lx + _pad, _ly, _listW - _newW - 3 * _pad, _btnH], _line, RULE_THIN] call FUNC(drawFrame);
[_root, [_lx + _pad * 2, _ly, _listW - _newW - 4 * _pad, _btnH], "FILTER - TYPE, GRID, CALLSIGN", _dim, 0.62, true, "left", true] call FUNC(drawText);

[_root, [_lx + _listW - _newW - _pad, _ly, _newW, _btnH], _accent] call FUNC(drawFill);
[_root, [_lx + _listW - _newW, _ly, _newW - _pad, _btnH], "NEW", _ground, 0.85, true, "center"] call FUNC(drawText);
// NEW OPENS THE RIGHT PANE, not a window. It closed the reader and put a
// second dialog up, so starting a message meant losing the traffic you started
// it about.
[_root, [_lx + _listW - _newW - _pad, _ly, _newW, _btnH], {
    ["", "", false] call FUNC(composeOpen);
}] call FUNC(drawHit);

_ly = _ly + _btnH + _padY;

// The tabs are filters over the same list. MINE is what you sent or were
// addressed in; ACK is what is waiting on you.
private _rows = _index select {
    _x isEqualType createHashMap
    && {if (GVAR(readerNet) == "ALL") then {
            // ALL hides what is muted - see the same rule in the rail.
            ([_x getOrDefault ["boxId", ""], _x getOrDefault ["threadId", ""]] call EFUNC(messaging,netLevel)) isEqualTo 0
        } else {
            (_x getOrDefault ["boxId", ""]) in [format ["B:%1", GVAR(readerNet)], format ["G:%1", GVAR(readerNet)]]
            || {GVAR(readerNet) == "SQUAD" && {(_x getOrDefault ["boxId", ""]) == _squadBox}}
        }}
};

private _uid = getPlayerUID player;
private _tabbed = switch (GVAR(readerTab)) do {
    // The engine's states are uppercase - lowercase "closed" matched nothing.
    case "open": {_rows select {!((_x getOrDefault ["status", ""]) in ["CLOSED", "ABORTED"])}};
    case "mine": {_rows select {(_x getOrDefault ["claimedBy", ""]) == _uid}};
    case "ack": {_rows select {(_x getOrDefault ["unread", 0]) > 0}};
    default {_rows};
};

private _tabW = _listW / 4;
{
    _x params ["_key", "_label", "_n"];
    private _on = _key == GVAR(readerTab);
    private _tx = _lx + _forEachIndex * _tabW;

    [_root, [_tx + _pad, _ly, _tabW, _rowH], format ["%1 %2", _label, _n], ([_mute, _accent] select _on), 0.62, true, "left", true] call FUNC(drawText);
    if (_on) then {
        [_root, [_tx + _pad, _ly + _rowH - RULE_THICK * pixelH, _tabW - _pad, RULE_THICK * pixelH], _accent] call FUNC(drawFill);
    };

    private _hit = [_root, [_tx, _ly, _tabW, _rowH], {
        params ["_ctrl"];
        GVAR(readerTab) = _ctrl getVariable [QGVAR(tab), "all"];
        {[] call FUNC(readerDraw)} call CBA_fnc_execNextFrame;
    }] call FUNC(drawHit);
    _hit setVariable [QGVAR(tab), _key];
} forEach [
    ["all", "ALL", count _rows],
    ["open", "OPEN", count (_rows select {!((_x getOrDefault ["status", ""]) in ["CLOSED", "ABORTED"])})],
    ["mine", "MINE", count (_rows select {(_x getOrDefault ["claimedBy", ""]) == _uid})],
    ["ack", "UNREAD", count (_rows select {(_x getOrDefault ["unread", 0]) > 0})]
];

_ly = _ly + _rowH;
[_root, [_lx, _ly, _listW, RULE_THICK * pixelH], _ink] call FUNC(drawFill);
_ly = _ly + RULE_THICK * pixelH;

// ONE ROW PER THREAD. The index holds a row per thread PER MAILBOX, and a
// report addressed to a shared net is filed in that net and in the sender's own
// box - so under ALL the sender saw everything they had sent twice.
private _byThread = createHashMap;
{
    private _id = _x getOrDefault ["threadId", ""];
    private _have = _byThread getOrDefault [_id, createHashMap];

    // Keep the row that knows the most: unread is counted per mailbox, and the
    // one with traffic on it is the one worth showing.
    if (_have isEqualTo createHashMap
        || {(_x getOrDefault ["unread", 0]) > (_have getOrDefault ["unread", 0])}) then {
        _byThread set [_id, _x];
    };
} forEach _tabbed;
_tabbed = values _byThread;

// Newest first.
private _keyed = [];
{_keyed pushBack [_x getOrDefault ["lastActivity", 0], _forEachIndex]} forEach _tabbed;
_keyed sort false;
_tabbed = _keyed apply {_tabbed # (_x # 1)};

if (_tabbed isEqualTo []) then {
    [_root, [_lx + _pad, _ly + _padY, _listW - 2 * _pad, _rowH], "NO TRAFFIC", _dim, 0.85] call FUNC(drawText);
};

private _entryH = _rowH * 2.9;
{
    private _entry = _x;
    private _ey = _ly + _forEachIndex * _entryH;
    if (_ey + _entryH > _h) exitWith {};

    private _threadId = _entry getOrDefault ["threadId", ""];
    private _selected = _threadId == GVAR(readerThread);
    private _flash = (_entry getOrDefault ["priority", ""]) == "high";
    private _closed = (_entry getOrDefault ["status", ""]) in ["CLOSED", "ABORTED"];

    if (_selected || _flash) then {
        [_root, [_lx, _ey, _listW, _entryH], [_accent # 0, _accent # 1, _accent # 2, 0.12]] call FUNC(drawFill);
        [_root, [_lx, _ey, 4 * pixelW, _entryH], _accent] call FUNC(drawFill);
    };

    private _bodyInk = [_ink, _dim] select _closed;
    private _left = _lx + _pad + ([0, 4 * pixelW] select (_selected || _flash));

    // The chip, measured off the glyph advance so it hugs its word.
    private _badge = switch (_entry getOrDefault ["priority", ""]) do {
        case "high": {"FLASH"};
        case "medium": {"PRIORITY"};
        default {"ROUTINE"};
    };
    private _chipSize = 0.62;
    private _chipFontH = ([_chipSize] call FUNC(textH)) / 1.25;
    private _chipW = (2 * count (toArray _badge) - 1) * 0.46 * _chipFontH * pixelW / pixelH + 12 * pixelW;
    private _chipH = _rowH * 0.6;
    private _chipY = _ey + _padY;

    if (_flash) then {
        [_root, [_left, _chipY, _chipW, _chipH], _accent] call FUNC(drawFill);
    } else {
        [_root, [_left, _chipY, _chipW, _chipH], _line, RULE_THIN] call FUNC(drawFrame);
    };
    [_root, [_left + 3 * pixelW, _chipY, _chipW, _chipH], _badge, ([_mute, _ground] select _flash), _chipSize, true, "left", true] call FUNC(drawText);

    private _type = ([_entry getOrDefault ["templateId", ""]] call EFUNC(messaging,template)) getOrDefault ["short", ""];
    [_root, [_left + _chipW + 6 * pixelW, _chipY, _listW * 0.45, _chipH], _type, _mute, _chipSize, true, "left", true] call FUNC(drawText);
    [_root, [_lx + _listW * 0.6, _chipY, _listW * 0.4 - _pad, _chipH], [_entry getOrDefault ["lastActivity", 0]] call FUNC(clock), _mute, _chipSize, true, "right"] call FUNC(drawText);

    [_root, [_left, _ey + _rowH * 0.85, _listW - _pad * 2, _rowH], _entry getOrDefault ["subject", ""], _bodyInk, 1, true] call FUNC(drawText);

    private _meta = [];
    private _replies = _entry getOrDefault ["replies", 0];
    if (_replies > 0) then {_meta pushBack format ["%1 REPLIES", _replies]};
    if ((_entry getOrDefault ["unread", 0]) > 0) then {_meta pushBack format ["%1 UNREAD", _entry get "unread"]};
    if (_closed) then {_meta pushBack "CLOSED"};

    [_root, [_left, _ey + _rowH * 1.9, _listW - _pad * 2, _rowH], _meta joinString " - ", ([_mute, _accent] select ((_entry getOrDefault ["unread", 0]) > 0)), 0.6, true, "left", true] call FUNC(drawText);
    [_root, [_lx, _ey + _entryH - RULE_THIN * pixelH, _listW, RULE_THIN * pixelH], _line] call FUNC(drawFill);

    private _hit = [_root, [_lx, _ey, _listW, _entryH], {
        params ["_ctrl"];
        private _id = _ctrl getVariable [QGVAR(threadId), ""];
        if (_id == "") exitWith {};

        GVAR(readerThread) = _id;

        // A dropdown belongs to the thread it was opened on.
        GVAR(readerMarkers) = false;

        [_id, {{[] call FUNC(readerDraw)} call CBA_fnc_execNextFrame}] call EFUNC(messaging,open);
        {[] call FUNC(readerDraw)} call CBA_fnc_execNextFrame;
    }] call FUNC(drawHit);
    _hit setVariable [QGVAR(threadId), _threadId];
} forEach _tabbed;

// ============================================================== the detail ==
private _input = _display displayCtrl IDC_RD_INPUT;

// COMPOSING IS A STATE OF THIS PANE. NEW and + TEMPLATE switch what the right
// third of the screen is showing; the nets, the list and the thread you are
// answering all stay on screen while you write.
if (GVAR(composeOn)) exitWith {
    [[_detailX, _detailW]] call FUNC(composePane);
    [] call _fnc_closeButton;
};

// A NET IS A CONVERSATION, NOT A FOLDER OF THEM. With no single thread picked,
// the pane shows the whole net in the order it was said - so a message sent to
// HQ is visible in HQ, which it was not when this said SELECT A THREAD and made
// the player go and find their own traffic.
//
// A thread is still openable from the list on the left for anyone who wants one
// report on its own; this is what the pane shows the rest of the time.
if (GVAR(readerThread) == "") exitWith {
    // The reply box is a child of the content group, so a rebuilt group has
    // already taken it away; parked here only if one somehow survives.
    if (!isNull _input) then {
        _input ctrlSetPosition [0, 0, 0, 0];
        _input ctrlCommit 0;
    };

    // ALL is a VIEW - every box at once - so it asks for "" and gets the whole
    // stream. The name-to-box rule lives in FUNC(netBox) because three copies of
    // it had already drifted apart.
    private _boxId = [GVAR(readerNet)] call FUNC(netBox);
    ([_boxId] call EFUNC(messaging,netStream)) params ["_stream", "_pending"];

    [_stream, _pending, [_detailX, _detailW]] call FUNC(readerNetView);
    [] call _fnc_closeButton;
};

private _cached = (missionNamespace getVariable [QEGVAR(messaging,cache), createHashMap]) getOrDefault [GVAR(readerThread), []];
if (_cached isEqualTo []) exitWith {
    if (!isNull _input) then {
        _input ctrlSetPosition [0, 0, 0, 0];
        _input ctrlCommit 0;
    };
    [_root, [_detailX + _pad, _h * 0.45, _detailW, _rowH], "FETCHING...", _dim, 1, true, "center"] call FUNC(drawText);
};

_cached params ["_thread", "_messages"];
[_thread, _messages, [_detailX, _detailW]] call FUNC(readerThreadView);
[] call _fnc_closeButton;
