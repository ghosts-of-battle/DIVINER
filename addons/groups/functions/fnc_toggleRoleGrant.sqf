#include "script_component.hpp"
/*
    File: fn_toggleRoleGrant.sqf
    Author: Dom -- Tinkered with by YonV
    Description: (Server) Toggles a role-access grant for a player, bypassing the
        Role_Access whitelist. Temporary grants last for the mission; persistent grants
        are stored in the server's profileNamespace and reloaded by initServer.
*/
params [
    ["_unit",objNull,[objNull]],
    ["_persistent",false,[false]],
    ["_admin",objNull,[objNull]]
];

if (!isServer) exitWith {};
private _uid = getPlayerUID _unit;
if (_uid isEqualTo "") exitWith {};

private _granted = !(_uid in YMF_roleGrants);
if (_granted) then {
    YMF_roleGrants pushBackUnique _uid;
} else {
    YMF_roleGrants deleteAt (YMF_roleGrants find _uid);
};
publicVariable "YMF_roleGrants";

if (_persistent) then {
    private _stored = profileNamespace getVariable ["YMF_roleGrants_persistent",[]];
    if (_granted) then {
        _stored pushBackUnique _uid;
    } else {
        private _index = _stored find _uid;
        if (_index isNotEqualTo -1) then {_stored deleteAt _index};
    };
    profileNamespace setVariable ["YMF_roleGrants_persistent",_stored];
    saveProfileNamespace;
};

private _mode = ["(this mission only)","(stored on the server)"] select _persistent;
if (_granted) then {
    [
        QGHOSTGVAR(notify,post),
        ["Role Access", format ["You have been granted access to all roles %1.",_mode], NOTE_GOOD, sideUnknown],
        _unit
    ] call CBA_fnc_targetEvent;
    if (!isNull _admin) then {
        [
            QGHOSTGVAR(notify,post),
            ["Role Access", format ["Granted %1 role access %2.",name _unit,_mode], NOTE_GOOD, sideUnknown],
            _admin
        ] call CBA_fnc_targetEvent;
    };
} else {
    [
        QGHOSTGVAR(notify,post),
        ["Role Access", format ["Your role access grant has been removed %1.",_mode], NOTE_WARN, sideUnknown],
        _unit
    ] call CBA_fnc_targetEvent;
    if (!isNull _admin) then {
        [
            QGHOSTGVAR(notify,post),
            ["Role Access", format ["Revoked %1's role access %2.",name _unit,_mode], NOTE_WARN, sideUnknown],
            _admin
        ] call CBA_fnc_targetEvent;
    };
};
