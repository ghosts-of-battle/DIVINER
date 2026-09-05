#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_svcConfigure

Description:
    Hands the pacdb service's address and key to the ghostd_pacdb extension
    - from the two CBA server settings (initSettings.inc.sqf), which a
    rented game server can take where it cannot take a file. With the URL
    setting empty nothing is handed over and the extension uses what it
    finds for itself: GHOSTD_PACDB_URL / GHOSTD_PACDB_KEY in the server's
    environment, then pacdb.json in the server's root.

    Server only, once, at boot step 3 before the first request.

Parameters:
    None

Returns:
    Where the address came from: "setting", "environment" (nothing handed
    over), or "" when the extension did not take it <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

if (!isServer) exitWith {""};

private _url = missionNamespace getVariable [QGVAR(serviceUrl), ""];
private _key = missionNamespace getVariable [QGVAR(serviceKey), ""];
if !(_url isEqualType "") then {_url = ""};
if !(_key isEqualType "") then {_key = ""};
_url = trim _url;
_key = trim _key;

if (_url isEqualTo "") exitWith {"environment"};

("ghostd_pacdb" callExtension ["configure", [_url, _key]]) params [["_text", "", [""]], "", ["_err", 0, [0]]];
if (_err isNotEqualTo 0 || _text isNotEqualTo "ok") exitWith {
    WARNING_2("pacdb extension did not take the service address from the CBA setting (error %1, said '%2') - is ghostd_pacdb_x64.dll / .so in the mod folder or the server's Arma root?",_err,_text);
    if (_err isNotEqualTo 0) then {GVAR(svcMissing) = true};
    ""
};

private _shown = if ((_url find "@") > 0) then {(_url select [0, (_url find "://") + 3]) + "..." + (_url select [_url find "@"])} else {_url};
INFO_1("database address from the CBA setting: %1",_shown);
"setting"
