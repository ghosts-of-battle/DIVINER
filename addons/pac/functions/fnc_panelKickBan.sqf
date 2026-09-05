#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelKickBan

Description:
    KICK and BAN for the open player, with the console's own rules: the
    player must be on the server, must not be you, and you must be the logged
    in admin, because serverCommand takes nothing less. BAN asks first.

Parameters:
    0: Mode <STRING> - "kick" | "ban"

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_mode", "kick", [""]]];

private _red = [0.831, 0.267, 0.267, 1];
private _uid = GVAR(editUid);
if (_uid isEqualTo "") exitWith {};

private _hit = allPlayers select {(getPlayerUID _x) isEqualTo _uid};
if (_hit isEqualTo []) exitWith {
    ["TAC//PAC", "That player is not on the server.", _red] call EFUNC(notify,notify);
    playSound "addItemFailed";
};
private _unit = _hit # 0;

if (_unit isEqualTo player) exitWith {
    ["TAC//PAC", format ["You cannot %1 yourself!", _mode], _red] call EFUNC(notify,notify);
    playSound "addItemFailed";
};
if (call BIS_fnc_admin != 2) exitWith {
    ["TAC//PAC", "You must be the currently logged in admin to perform this action!", _red] call EFUNC(notify,notify);
    playSound "addItemFailed";
};

if (_mode isEqualTo "kick") exitWith {
    serverCommand format ["#kick %1", name _unit];
    [player, "kick", _uid, format ["kicked %1", name _unit]] remoteExec [QFUNC(adminLogAdd), 2];
    ["TAC//PAC", format ["Kicked %1.", name _unit], [0.4, 0.702, 0.4, 1]] call EFUNC(notify,notify);
};

// guiMessage blocks until answered, so it runs scheduled.
[_unit] spawn {
    params ["_unit"];
    private _yes = [format ["Are you sure you want to ban %1?", name _unit], "TAC//PAC", "Ban", "Cancel"] call BIS_fnc_guiMessage;
    if (_yes) then {
        serverCommand format ["#ban %1", name _unit];
        [player, "ban", getPlayerUID _unit, format ["banned %1", name _unit]] remoteExec ["ghostD_pac_fnc_adminLogAdd", 2];
        ["TAC//PAC", format ["Banned %1.", name _unit], [0.4, 0.702, 0.4, 1]] call ghostD_notify_fnc_notify;
    };
};
