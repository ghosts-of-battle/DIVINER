#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_templatesApply

Description:
    Registers the report deck the structure carries - the "templates"
    section, one entry per template in the shape FUNC(registerTemplate)
    takes - with TAC//MSG, on this machine. Skips any template already
    registered: on a mission that still ships GHOSTFR_Templates, messaging
    registered those at preInit and they win; on a mission whose deck lives
    in the database, this is the only registration there is.

    Runs on the server after the structure is final (FUNC(boot)) and on a
    client whenever it takes the server's structure (FUNC(takeServer)), so
    the registry is the same everywhere before anyone composes.

Parameters:
    None

Returns:
    How many templates were registered <NUMBER>

Author:
    YonV
---------------------------------------------------------------------------- */

if (isNil "ghostD_messaging_fnc_registerTemplate") exitWith {0};

private _deck = GVAR(structure) getOrDefault ["templates", createHashMap];
if !(_deck isEqualType createHashMap) exitWith {0};

private _have = missionNamespace getVariable ["ghostD_messaging_templateIds", []];
private _made = 0;
private _ids = keys _deck;
_ids sort true;
{
    if (_x in _have) then {continue};
    private _t = _deck get _x;
    if !(_t isEqualType createHashMap) then {continue};
    private _lines = _t getOrDefault ["lines", []];
    private _options = _t getOrDefault ["options", []];
    if !(_lines isEqualType [] && _options isEqualType []) then {continue};
    if (([_x, _t getOrDefault ["title", _x], _t getOrDefault ["short", ""], _lines, _options] call ghostD_messaging_fnc_registerTemplate) isNotEqualTo "") then {
        _made = _made + 1;
    };
} forEach _ids;

if (_made > 0) then {INFO_1("report deck from the structure: %1 template(s) registered",_made)};
_made
