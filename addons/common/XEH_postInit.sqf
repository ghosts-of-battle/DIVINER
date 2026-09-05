#include "script_component.hpp"

// --- BI's Civilian Presence FSM, without BI's Civilian Presence module -------
// THIRTY RPT ERRORS A SECOND, FOR THE WHOLE MISSION. The log filled with
//
//   Error in expression <time > _t>   Error Undefined variable in expression: _t
//
// preceded once by the line that causes it:
//
//   _threat = [_this,_threatsNew] call bis_fnc_cp_main;  _t = time + ...
//   Error Undefined variable in expression: bis_fnc_cp_main
//
// Those five bis_fnc_cp_* functions are NOT in CfgFunctions. BI's Civilian
// Presence MODULE registers them at runtime when it initialises
// (A3\Modules_F_Tacops\Ambient\CivilianPresence\init.sqf). But the danger FSM
// that calls them is baked into the UNIT CLASSES as fsmDanger, so any civilian
// carrying it runs the FSM whether that module is in the mission or not - and
// ALiVE's ambient civilian placement puts hundreds of them down. With the
// function missing the FSM's first state throws before it can set _t, so its
// transition condition `time > _t` then throws every frame, for every civilian,
// for the rest of the mission.
//
// So the functions are registered here if nothing else has registered them.
// This is BI's own call, on BI's own files, with BI's own names - not a
// reimplementation. main.sqf keeps all its state on the unit and needs nothing
// from the module, so the FSM behaves exactly as intended once it can find it.
//
// EVERY MACHINE, because a danger FSM runs wherever its unit is local.
if (isNil "bis_fnc_cp_main") then {
    [
        "\A3\Modules_F_Tacops\Ambient\CivilianPresence\Functions\",
        "bis_fnc_cp_",
        ["debug", "getQueueDelay", "main", "addThreat", "getSafespot"]
    ] call BIS_fnc_loadFunctions;
};

if (hasInterface) then {
    // THE MACHINE RUNNING THE SERVER IS ALREADY THE ADMIN. There is nothing for
    // a host or a single player to log in TO - `#login` waits on
    // serverCommandAvailable "#kick", which never becomes true in single player,
    // so on a dev box the flag was never set and every `#ghost` command was
    // silently swallowed. That is not a subtle failure to debug: the surface is
    // deliberately silent to non-admins, so it looks exactly like a broken mod.
    //
    // In a real multiplayer session only the host satisfies this, and a
    // dedicated server has no player to hold the flag at all - so it costs
    // nothing there and makes the tools usable where they are actually used.
    if (isServer) then {
        [{!isNull player}, {
            player setVariable [QGVAR(isAdmin), true, true];
        }, [], 30] call CBA_fnc_waitUntilAndExecute;
    };

    ["login", {
        [{IS_ADMIN}, {
            player setVariable [QGVAR(isAdmin), true, true];
        }, nil, 5] call CBA_fnc_waitUntilAndExecute;
    }, "all"] call CBA_fnc_registerChatCommand;

    ["logout", {
        if (player getVariable [QGVAR(isAdmin), false]) then {
            player setVariable [QGVAR(isAdmin), false, true];
        };
    }, "all"] call CBA_fnc_registerChatCommand;

    ["unit", {
        params ["_newPlayer", "_oldPlayer"];

        if (IS_ADMIN) then {
            _newPlayer setVariable [QGVAR(isAdmin), true, true];
        };

        if (_oldPlayer getVariable [QGVAR(isAdmin), false]) then {
            _oldPlayer setVariable [QGVAR(isAdmin), false, true];
        };
    }, true] call CBA_fnc_addPlayerEventHandler;
};

// Server end of the admin debug commands: run the handler here and reply to the
// admin who typed it. Registered unconditionally so a command added by any
// addon works without that addon knowing about the transport.
if (isServer) then {
    [QGVAR(debugRun), {
        params ["_name", "_args", "_caller"];
        private _entry = (missionNamespace getVariable [QGVAR(debugCommands), createHashMap]) getOrDefault [_name, []];
        if (_entry isEqualTo []) exitWith {};
        private _reply = [_args, _caller] call (_entry select 2);
        if (!isNil "_reply") then { [_reply, _caller] call FUNC(debugReply) };
    }] call CBA_fnc_addEventHandler;
};

// Always-available commands. Everything else is registered by the addon that
// owns it, so this list stays the baseline the harness is proven with.
["state", "list placed ghost modules and their armed state", {
    private _out = [];
    {
        private _cls = typeOf _x;
        if (_cls select [0, 13] isEqualTo "ghostD_module") then {
            _out pushBack format ["%1 @ %2", _cls, mapGridPosition _x];
        };
    } forEach (entities "Logic");
    if (_out isEqualTo []) then { "no ghost modules placed" } else { _out joinString " | " }
}] call FUNC(addDebugCommand);

["markers", "delete every intel marker on my machine", {
    private _n = 0;
    {
        if (_x select [0, 6] isEqualTo "ghost_") then { deleteMarkerLocal _x; _n = _n + 1 };
    } forEach allMapMarkers;
    format ["%1 markers cleared locally", _n]
}, true] call FUNC(addDebugCommand);

// The alert bus: every ghost system that does something TO the players posts
// here, and the devices draw from one place. See FUNC(alert).
GVAR(alerts) = [];
[QGVAR(alert), FUNC(onAlert)] call CBA_fnc_addEventHandler;

// --- the threat board -------------------------------------------------------
// What each side KNOWS: side -> [[id, side, target, pos, error, seen, first,
// sources, object], ...]. Server only - one authoritative picture, read
// through FUNC(contactGet) and never touched directly.
GVAR(playerSide) = west;

if (isServer) then {
    GVAR(boards) = createHashMap;
    GVAR(contactSeq) = 0;

    // Sensors post here; the board files it. One raise feeds every
    // commanders - a sensor never needs to know who is listening.
    [QGVAR(contact), {
        params ["_detectorSide", "_victimSide", "_pos", "_error", "_source"];
        [_detectorSide, _victimSide, _pos, _error, _source] call FUNC(contactReport);
    }] call CBA_fnc_addEventHandler;
};
