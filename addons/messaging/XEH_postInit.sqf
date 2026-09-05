#include "script_component.hpp"

// Everything crosses the wire on CBA's event channel rather than a raw
// remoteExec. patrol_base made the same call for the same reason: it is a
// channel a mission's CfgRemoteExec cannot close, and it is what the rest of
// the mod already uses. The trade is that the server cannot read the sending
// machine off the engine, so it takes the sender from the unit it was handed
// and checks that unit is a live player - see srvSubmit.

if (isServer) then {
    [QGVAR(submit), LINKFUNC(srvSubmit)] call CBA_fnc_addEventHandler;
    [QGVAR(requestIndex), LINKFUNC(srvRequestIndex)] call CBA_fnc_addEventHandler;
    [QGVAR(requestThread), LINKFUNC(srvRequestThread)] call CBA_fnc_addEventHandler;
    [QGVAR(markRead), LINKFUNC(srvMarkRead)] call CBA_fnc_addEventHandler;
    [QGVAR(claim), LINKFUNC(srvClaim)] call CBA_fnc_addEventHandler;

    // TRAFFIC DOES NOT SURVIVE A RESTART, and that is the design rather than a
    // gap in it. The store is built empty in preInit and nothing reloads it: the
    // mailboxes the mission named are recreated here, and they are recreated
    // empty. Every thread on the server belongs to the session that is running.
    //
    // What was here before wrote shared mailboxes to the SERVER's profile at
    // MPEnded and read them back next start. That tied a squad's paperwork to
    // one machine's .vars.Arma3Profile, loaded the whole lot into memory with no
    // way to query it, and meant a thread could outlive the players, the groups
    // and the callsigns it referred to - so a net came up already full of last
    // week's traffic addressed to people who were not on it.
    //
    // Everything the server does at startup reads a setting - which mailboxes
    // exist, how long a thread may idle - so it waits for CBA to finish settling
    // settings rather than reading nil.
    [{
        // THE UNIT'S OWN LIST WINS - TAC//PAC's nets section when the unit
        // keeps its nets in the database, else the mission's GHOSTFR_Nets
        // { nets[] = {{name, description}, ...} }, else the setting - see
        // FUNC(netNames). Nets that only arrive with PAC's boot are opened
        // then, by FUNC(netsApply).
        private _names = [] call FUNC(netNames);

        {
            [_x, "named", _x] call FUNC(srvBox);
        } forEach _names;

        [FUNC(srvSweep), SWEEP_INTERVAL, []] call CBA_fnc_addPerFrameHandler;

        INFO_1("store starts empty - %1 mailbox(es) open, no traffic carried over",count GVAR(boxes));
    }] call EFUNC(common,runAfterSettingsInit);
};

if (hasInterface) then {
    // The cache holds threads the server has already sent. When the store is
    // emptied under it - see msg.clear - it is holding threads that no longer
    // exist, and an index refresh alone would not clear them.
    [QGVAR(cacheClear), {
        GVAR(cache) = createHashMap;
    }] call CBA_fnc_addEventHandler;

    [QGVAR(indexPush), LINKFUNC(cltIndex)] call CBA_fnc_addEventHandler;
    [QGVAR(receive), LINKFUNC(cltReceive)] call CBA_fnc_addEventHandler;
    [QGVAR(threadPush), LINKFUNC(cltThread)] call CBA_fnc_addEventHandler;
    [QGVAR(marker), LINKFUNC(cltMarker)] call CBA_fnc_addEventHandler;

    // A refusal is told to the sender and nobody else. It is the server's half
    // of the validation the client already ran, so it only fires when the two
    // disagreed - a stale template, or a thread that changed state while the
    // form was open.
    [QGVAR(reject), {
        params [["_templateId", "", [""]], ["_why", "", [""]]];
        private _template = [_templateId] call FUNC(template);
        [_template getOrDefault ["short", "MESSAGE"], _why, "high"] call FUNC(notify);

        // AND IN CHAT. The notification stack is an RscTitles layer, so anything
        // drawn as a dialog is in front of it - and the screen a refusal is
        // about is always a dialog. A message that says why nothing happened is
        // worthless if it is behind the thing that did nothing.
        systemChat format ["[%1] %2", _template getOrDefault ["short", "MESSAGE"], _why];
    }] call CBA_fnc_addEventHandler;

    // Ask once the player exists. A JIP client that asks before its unit is
    // assigned gets an empty index and never asks again.
    [{!isNull player && {!isNull (group player)}}, {
        [] call FUNC(request);

        // After the index has been asked for, not before - the seed goes through
        // the server like any other message and comes back on the same channel.
        if (GVAR(seedTest)) then {
            [FUNC(seedTest), [], 3] call CBA_fnc_waitAndExecute;
        };
    }] call CBA_fnc_waitUntilAndExecute;
};

// --- Admin diagnostics ------------------------------------------------------
// WHERE IT STOPPED, not whether it worked. The chain has four links - client
// submits, server files, server delivers, client indexes - and every one of them
// fails quietly by design: a refusal is told only to the sender, and a delivery
// to a box with nobody in it is a legitimate no-op. These say which link is
// holding the traffic.

["msg.state", "messaging store and what this player can see", {
    params ["_args", "_caller"];
    private _visible = [_caller] call FUNC(srvBoxesFor);
    format [
        "enabled %1 | %2 thread(s), %3 message(s), %4 box(es) | you see: %5",
        GVAR(enabled),
        count GVAR(threads),
        count GVAR(messages),
        count GVAR(boxes),
        [_visible joinString ", ", "nothing"] select (_visible isEqualTo [])
    ]
}] call EFUNC(common,addDebugCommand);

["msg.boxes", "list mailboxes, who is in them and how many threads they hold", {
    params ["_args", "_caller"];
    if (GVAR(boxes) isEqualTo createHashMap) exitWith {"no mailboxes exist yet"};

    {
        [
            format [
                "  %1 (%2) - %3 thread(s), %4 member(s) here now",
                _x,
                _y get "kind",
                count (_y getOrDefault ["threads", []]),
                count ([_x] call FUNC(srvMembers))
            ],
            _caller
        ] call EFUNC(common,debugReply);
    } forEach GVAR(boxes);
    nil
}] call EFUNC(common,addDebugCommand);

["msg.threads", "list threads: id, status, subject, boxes", {
    params ["_args", "_caller"];
    if (GVAR(threads) isEqualTo createHashMap) exitWith {"no threads have been filed"};

    {
        [
            format [
                "  %1 %2 [%3] %4 - %5 msg, on %6, tags %7",
                _x,
                _y get "priority",
                _y get "status",
                _y get "subject",
                count (_y get "messages"),
                [_y getOrDefault ["box", ""], "unfiled"] select ((_y getOrDefault ["box", ""]) isEqualTo ""),
                [(_y getOrDefault ["tags", []]) joinString " ", "none"] select ((_y getOrDefault ["tags", []]) isEqualTo [])
            ],
            _caller
        ] call EFUNC(common,debugReply);
    } forEach GVAR(threads);
    nil
}] call EFUNC(common,addDebugCommand);

// --- Solo testing -----------------------------------------------------------
// A messaging system needs two people to prove, and there is rarely a second
// one on a dev box. These file traffic FROM somebody else through the real
// server path - so it arrives unread, raises a notification, and lands on the
// thread spine exactly as another player's would. Only the call sign is a lie.

["msg.inbound", "traffic from someone else, to you: msg.inbound [text]", {
    params ["_args", "_caller"];
    private _text = [_args joinString " ", "All callsigns, HQ. Report REDCON when set. Out."] select (_args isEqualTo []);
    private _key = ((["freetext"] call FUNC(template)) getOrDefault ["order", []]) param [0, "Text.A"];

    [_caller, format ["test:%1:%2", diag_frameNo, floor random 1e6], "freetext", [[_key, _text]],
        [format ["P:%1", getPlayerUID _caller]], "", "", "HQ SIGNALS"] call FUNC(srvSubmit);
    "filed as HQ SIGNALS - it should arrive unread, with a notification"
}] call EFUNC(common,addDebugCommand);

["msg.flash", "a FLASH CASEVAC from someone else, on your grid", {
    params ["_args", "_caller"];
    private _grid = mapGridPosition _caller;

    [_caller, format ["test:%1:%2", diag_frameNo, floor random 1e6], "casevac", [
        ["Line1.A", getPosATL _caller],
        ["Line2.A", 2],
        ["Line3.A", 1],
        ["Line4.B", true],
        ["Line5.A", "SMOKE"],
        ["Line5.B", format ["Green, 200m east of %1", _grid]]
    ], [format ["P:%1", getPlayerUID _caller]], "", "", "DOC RILEY"] call FUNC(srvSubmit);
    "FLASH CASEVAC filed - accent row, chip, card and alert all come off this one"
}] call EFUNC(common,addDebugCommand);

["msg.tag", "someone calls a squad out by name on the net: msg.tag <TAG> [text]", {
    params ["_args", "_caller"];
    private _tag = toUpper (_args param [0, ""]);
    if (_tag isEqualTo "") exitWith {"usage: msg.tag <TAG> [text] - a squad name, a job (MED, LDR, ENG, EOD, UAV), a callsign or a UID"};

    private _net = ((GVAR(namedBoxes) splitString ",") apply {trim _x} select {_x != ""}) param [0, "HQ"];
    private _text = [(_args select [1]) joinString " ", format ["%1, HQ. Move to the contact and report when set. Out.", _tag]] select (count _args < 2);
    private _key = ((["freetext"] call FUNC(template)) getOrDefault ["order", []]) param [0, "Text.A"];

    // Through srvSubmit like everything else, so this proves the real path: it
    // is filed on the net, NOT sent to the tagged squad, and they are woken up
    // about it where it lies.
    [_caller, format ["test:%1:%2", diag_frameNo, floor random 1e6], "freetext", [[_key, _text]],
        [format ["B:%1", _net]], "", "", "HQ SIGNALS", [_tag]] call FUNC(srvSubmit);

    private _who = [[_tag]] call FUNC(srvTagged);
    format [
        "filed on %1 tagged %2 - it reaches %3",
        _net, _tag,
        [(_who apply {name _x}) joinString ", ", "NOBODY on the server right now"] select (_who isEqualTo [])
    ]
}] call EFUNC(common,addDebugCommand);

["msg.reply", "someone else answers a thread: msg.reply <threadId> [text]", {
    params ["_args", "_caller"];
    private _threadId = toUpper (_args param [0, ""]);
    if (_threadId isEqualTo "") exitWith {"usage: msg.reply <threadId> [text] - ids are in msg.threads"};
    if !(_threadId in GVAR(threads)) exitWith {format ["no thread '%1' - try msg.threads", _threadId]};

    private _text = [(_args select [1]) joinString " ", "Wheels up, eight minutes out. Confirm marking on final."] select (count _args < 2);
    private _key = ((["freetext"] call FUNC(template)) getOrDefault ["order", []]) param [0, "Text.A"];

    [_caller, format ["test:%1:%2", diag_frameNo, floor random 1e6], "freetext", [[_key, _text]],
        [], _threadId, "", "ROTARY 1-1"] call FUNC(srvSubmit);
    format ["ROTARY 1-1 answered %1", _threadId]
}] call EFUNC(common,addDebugCommand);

["msg.clear", "empty the whole store and every client's index", {
    GVAR(threads) = createHashMap;
    GVAR(messages) = createHashMap;
    GVAR(nonces) = createHashMap;

    // The mailboxes stay - they are the mission's configuration, not traffic -
    // but they let go of the threads that no longer exist.
    {_y set ["threads", []]} forEach GVAR(boxes);

    [QGVAR(cacheClear), []] call CBA_fnc_globalEvent;
    {[_x] call FUNC(srvRequestIndex)} forEach allPlayers;
    "store emptied and every index refreshed"
}] call EFUNC(common,addDebugCommand);

["msg.send", "file a test message to yourself: msg.send [text]", {
    params ["_args", "_caller"];
    private _text = [_args joinString " ", "Admin test - if you can read this in TAC//MSG the chain is intact"] select (_args isEqualTo []);
    private _key = ((["freetext"] call FUNC(template)) getOrDefault ["order", []]) param [0, "Text.A"];

    // Through the same event the client uses, so this proves the server half
    // exactly as a player's send would.
    [_caller, format ["admin:%1:%2", diag_frameNo, floor random 1e6], "freetext", [[_key, _text]], [format ["P:%1", getPlayerUID _caller]], "", ""] call FUNC(srvSubmit);
    "filed - it should be in your reader within a frame"
}] call EFUNC(common,addDebugCommand);

// LOCAL, because this is the far end of the chain: what THIS machine has been
// told, which is the half a server-side dump cannot see.
["msg.mine", "what your own client has in its index", {
    private _rows = missionNamespace getVariable [QGVAR(index), []];
    if (_rows isEqualTo []) exitWith {"your index is empty - nothing has been delivered to you"};

    {
        [format [
            "  %1 in %2 [%3] %4 - %5 unread",
            _x getOrDefault ["threadId", "?"],
            _x getOrDefault ["boxId", "?"],
            _x getOrDefault ["status", "?"],
            _x getOrDefault ["subject", "?"],
            _x getOrDefault ["unread", 0]
        ]] call EFUNC(common,debugReply);
    } forEach _rows;
    nil
}, true] call EFUNC(common,addDebugCommand);
