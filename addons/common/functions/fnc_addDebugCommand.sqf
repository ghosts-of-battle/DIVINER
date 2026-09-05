#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_addDebugCommand

Description:
    Registers an admin chat command. Every ghost addon registers its own, so the
    dispatcher never has to know what exists.

    Commands are typed into any chat channel as `#ghost <name> [args...]` by a
    player holding the admin flag. The message is swallowed - it is never
    broadcast, and a non-admin typing the same thing gets no reply and no hint
    that the surface is there.

    The handler runs on the SERVER by default, which is what most test commands
    want (spawning, registry dumps, forcing module state). Pass _local for the
    ones that must run on the caller's machine - HUD tests, marker clears.

Parameters:
    _name    : STRING - command name, e.g. "ew.zones". Case-insensitive.
    _help    : STRING - one line shown by `#ghost help`.
    _code    : CODE   - handler. Receives [_args, _caller]:
                          _args   ARRAY of STRING, whatever followed the name
                          _caller OBJECT, the admin who typed it
                        Return a STRING to reply to the caller, or nil for none.
    _local   : BOOL   - true = run on the caller's machine. Optional, default false.

Returns:
    BOOL - true if registered, false if the name was already taken.

Example:
    ["ew.zones", "list live EW zones", {
        params ["_args", "_caller"];
        format ["%1 zones", count (call EFUNC(jamming,getZones))]
    }] call ghostD_common_fnc_addDebugCommand

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_name", "", [""]], ["_help", "", [""]], ["_code", {}, [{}]], ["_local", false, [false]]];

if (_name isEqualTo "") exitWith { false };

if (isNil QGVAR(debugCommands)) then { GVAR(debugCommands) = createHashMap };

private _key = toLower _name;
if (_key in GVAR(debugCommands)) exitWith {
    diag_log text format ["[ghost] debug command '%1' already registered - ignored", _name];
    false
};

GVAR(debugCommands) set [_key, [_name, _help, _code, _local]];
true
