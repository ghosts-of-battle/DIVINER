#include "script_component.hpp"

// The tracker starts itself from the enabled setting's handler, which fires once
// settings are in. This is the belt to that brace: if the setting was already on
// before this addon's handler was registered, nothing else would have started
// the loop. Both paths are guarded, so the pair cannot double-start it.
if (hasInterface) then {
    ["CBA_settingsInitialized", {
        if (GVAR(enabled)) then {
            [] call FUNC(init);
        };
    }] call CBA_fnc_addEventHandler;

    // Members render as live unit icons on the map's own Draw event - see
    // FUNC(drawMembers). Hung once per map control; the flag survives the
    // display closing because the control does.
    addMissionEventHandler ["Map", {
        params ["_opened"];
        if (!_opened) exitWith {};
        private _map = findDisplay 12 displayCtrl 51;
        if (isNull _map || {_map getVariable [QGVAR(memberDraw), false]}) exitWith {};
        _map setVariable [QGVAR(memberDraw), true];
        _map ctrlAddEventHandler ["Draw", {_this call FUNC(drawMembers)}];
    }];
};

// --- Admin surface ----------------------------------------------------------
// Everything below is #ghost <command>, which ghost_common already gates on the
// admin flag and swallows for everyone else. Group tokens are matched by
// FUNC(findGroups): a fragment of a call sign, a side name, or "all".
//
// These run on the SERVER - it is the one machine that can see allGroups in full
// and the one whose setVariable reaches everybody.

["bft.list", "BFT state of every group: bft.list [group|side|all]", {
    params ["_args", "_caller"];
    private _token = _args param [0, "all"];
    private _groups = [_token] call FUNC(findGroups);
    if (_groups isEqualTo []) exitWith {format ["no group matching '%1'", _token]};

    [format ["%1 group(s):", count _groups], _caller] call EFUNC(common,debugReply);
    {
        [format ["  %1", [_x] call FUNC(describeGroup)], _caller] call EFUNC(common,debugReply);
    } forEach _groups;
    nil
}] call EFUNC(common,addDebugCommand);

["bft.on", "force a group's tracker on: bft.on <group|side|all>", {
    params ["_args"];
    private _token = _args param [0, ""];
    private _groups = [_token] call FUNC(findGroups);
    if (_groups isEqualTo []) exitWith {format ["no group matching '%1'", _token]};

    {
        _x setVariable [QGVAR(visible), true, true];
    } forEach _groups;
    format ["tracker ON for %1 group(s)", count _groups]
}] call EFUNC(common,addDebugCommand);

["bft.off", "force a group's tracker off: bft.off <group|side|all>", {
    params ["_args"];
    private _token = _args param [0, ""];
    private _groups = [_token] call FUNC(findGroups);
    if (_groups isEqualTo []) exitWith {format ["no group matching '%1'", _token]};

    {
        _x setVariable [QGVAR(visible), false, true];
    } forEach _groups;
    format ["tracker OFF for %1 group(s)", count _groups]
}] call EFUNC(common,addDebugCommand);

["bft.name", "rename a group: bft.name <group> <new name>", {
    params ["_args"];
    private _token = _args param [0, ""];
    private _name = (_args select [1]) joinString " ";
    if (_name isEqualTo "") exitWith {"usage: bft.name <group> <new name>"};

    private _groups = [_token] call FUNC(findGroups);
    if (_groups isEqualTo []) exitWith {format ["no group matching '%1'", _token]};

    {
        // setGroupIdGlobal has to run where the group is local, and a player
        // group is local to its leader's machine, not to the server.
        if (local _x) then {
            _x setGroupIdGlobal [_name];
        } else {
            [_x, [_name]] remoteExec ["setGroupIdGlobal", groupOwner _x];
        };
    } forEach _groups;
    format ["renamed %1 group(s) to '%2'", count _groups, _name]
}] call EFUNC(common,addDebugCommand);

["bft.icon", "set a group's marker icon: bft.icon <group> <icon>", {
    params ["_args"];
    private _token = _args param [0, ""];
    private _icon = toLower (_args param [1, ""]);
    if (_icon isEqualTo "") exitWith {format ["usage: bft.icon <group> <icon> - %1", GVAR(availableMarkerIcons) joinString ", "]};
    if !(_icon in GVAR(availableMarkerIcons)) exitWith {format ["no icon '%1' - %2", _icon, GVAR(availableMarkerIcons) joinString ", "]};

    private _groups = [_token] call FUNC(findGroups);
    if (_groups isEqualTo []) exitWith {format ["no group matching '%1'", _token]};

    {
        _x setVariable [QGVAR(type), _icon, true];
    } forEach _groups;
    format ["icon '%1' set on %2 group(s)", _icon, count _groups]
}] call EFUNC(common,addDebugCommand);

["bft.color", "set a group's marker colour: bft.color <group> <CfgMarkerColors class>", {
    params ["_args"];
    private _token = _args param [0, ""];
    private _color = _args param [1, ""];
    if (_color isEqualTo "") exitWith {"usage: bft.color <group> <CfgMarkerColors class, e.g. ColorBLUFOR>"};
    if !(isClass (configFile >> "CfgMarkerColors" >> _color)) exitWith {format ["no marker colour class '%1'", _color]};

    private _groups = [_token] call FUNC(findGroups);
    if (_groups isEqualTo []) exitWith {format ["no group matching '%1'", _token]};

    {
        _x setVariable [QGVAR(color), _color, true];
    } forEach _groups;
    format ["colour '%1' set on %2 group(s)", _color, count _groups]
}] call EFUNC(common,addDebugCommand);

["bft.net", "transmit nets: bft.net add|remove|clear <group> [net]", {
    params ["_args"];
    private _verb = toLower (_args param [0, ""]);
    private _token = _args param [1, ""];
    private _net = _args param [2, ""];

    private _groups = [_token] call FUNC(findGroups);
    if (_groups isEqualTo []) exitWith {format ["no group matching '%1'", _token]};

    private _reply = "usage: bft.net add|remove|clear <group> [net]";

    switch (_verb) do {
        case "add": {
            if (_net isEqualTo "") then {
                _reply = "usage: bft.net add <group> <net>";
            } else {
                {[_x, _net] call FUNC(networkAdd)} forEach _groups;
                _reply = format ["%1 group(s) now transmit on '%2'", count _groups, _net];
            };
        };
        case "remove": {
            if (_net isEqualTo "") then {
                _reply = "usage: bft.net remove <group> <net>";
            } else {
                {[_x, _net] call FUNC(networkRemove)} forEach _groups;
                _reply = format ["%1 group(s) off '%2'", count _groups, _net];
            };
        };
        case "clear": {
            {[_x] call FUNC(networkClear)} forEach _groups;
            _reply = format ["%1 group(s) transmit on nothing - they are invisible until given a net", count _groups];
        };
    };

    _reply
}] call EFUNC(common,addDebugCommand);

["bft.obs", "listen-only nets: bft.obs add|remove|clear <group> [net]", {
    params ["_args"];
    private _verb = toLower (_args param [0, ""]);
    private _token = _args param [1, ""];
    private _net = _args param [2, ""];

    private _groups = [_token] call FUNC(findGroups);
    if (_groups isEqualTo []) exitWith {format ["no group matching '%1'", _token]};

    private _reply = "usage: bft.obs add|remove|clear <group> [net]";

    switch (_verb) do {
        case "add": {
            if (_net isEqualTo "") then {
                _reply = "usage: bft.obs add <group> <net>";
            } else {
                {[_x, _net] call FUNC(networkAddObserver)} forEach _groups;
                _reply = format ["%1 group(s) now listen to '%2'", count _groups, _net];
            };
        };
        case "remove": {
            if (_net isEqualTo "") then {
                _reply = "usage: bft.obs remove <group> <net>";
            } else {
                {[_x, _net] call FUNC(networkRemoveObserver)} forEach _groups;
                _reply = format ["%1 group(s) no longer listen to '%2'", count _groups, _net];
            };
        };
        case "clear": {
            {[_x] call FUNC(networkClearObserved)} forEach _groups;
            _reply = format ["%1 group(s) listen to nothing but their own nets", count _groups];
        };
    };

    _reply
}] call EFUNC(common,addDebugCommand);

// Local, because it is this admin's own eyes: the god view is the only way to
// see the whole board, and switching it off is the only way to check what the
// players can actually see from inside a live mission.
["bft.view", "toggle your own BFT god view on or off", {
    GVAR(adminView) = !GVAR(adminView);
    if (!GVAR(adminGodView)) exitWith {
        "admin god view is disabled mission-wide - this changes nothing until it is switched back on"
    };
    format ["god view %1 - next redraw", ["OFF (player view)", "ON"] select GVAR(adminView)]
}, true] call EFUNC(common,addDebugCommand);
