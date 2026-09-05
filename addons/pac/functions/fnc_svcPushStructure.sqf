#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_svcPushStructure

Description:
    Writes the structure this server compiled from its mission config into
    the service, one document per config file, one per role and one per
    order (the shapes FUNC(svcStructure) reads) - the seed for a database
    that has none yet (FUNC(boot) step 2). Never called when the database
    already has a config: the database wins.

    The three bootstrap settings - unitId, serverId, sync - are left out of
    the settings document; they are the mission's.

Parameters:
    None

Returns:
    How many documents the extension took <NUMBER>

Author:
    YonV
---------------------------------------------------------------------------- */

if (!isServer) exitWith {0};

private _unit = GVAR(settings) getOrDefault ["unitId", ""];
private _now = [] call FUNC(stamp);
private _sent = 0;

private _fnc_push = {
    params ["_key", "_doc"];
    _doc set ["exportedAt", _now];
    _doc set ["from", "mission config, first boot"];
    if ([_key, [_doc, ""] call FUNC(toJson)] call FUNC(svcSave)) then {_sent = _sent + 1};
};

private _settings = +GVAR(settings);
{_settings deleteAt _x} forEach ["unitId", "serverId", "sync"];
[_unit + ".settings", createHashMapFromArray [["section", "settings"], ["items", _settings]]] call _fnc_push;

{
    [_unit + "." + _x, createHashMapFromArray [["section", _x], ["items", GVAR(structure) getOrDefault [_x, createHashMap]]]] call _fnc_push;
} forEach ["ranks", "skills", "awards", "statuses", "nets", "radio", "templates", "schemes", "promotion"];

{
    [_unit + ".role." + _x, createHashMapFromArray [["section", "role"], ["id", _x], ["role", _y]]] call _fnc_push;
} forEach (GVAR(structure) getOrDefault ["roles", createHashMap]);

private _orbat = GVAR(structure) getOrDefault ["orbat", createHashMap];
[_unit + ".orbat", createHashMapFromArray [
    ["section", "orbat"],
    ["faction", _orbat getOrDefault ["faction", ""]],
    ["groups", _orbat getOrDefault ["groups", []]],
    ["platoons", _orbat getOrDefault ["platoons", []]],
    ["radioNets", _orbat getOrDefault ["radioNets", []]]
]] call _fnc_push;

private _admins = GVAR(structure) getOrDefault ["admins", createHashMap];
private _ids = keys _admins;
_ids sort true;
[_unit + ".admins", createHashMapFromArray [["section", "admins"], ["ids", _ids], ["items", _admins]]] call _fnc_push;

{
    [_unit + ".opord." + _x, createHashMapFromArray [["section", "opord"], ["id", _x], ["order", _y]]] call _fnc_push;
} forEach (GVAR(structure) getOrDefault ["opords", createHashMap]);

_sent
