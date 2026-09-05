#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_objectFromString

Description:
    Resolves the string form of an object or group (as stored in a listbox's
    lbData) back to the thing itself, by matching `str _x` across the requested
    pool. Renamed from the original's `stringTo`.

Parameters:
    _string : STRING - the value to match.
    _type   : STRING - pool to search: "Obj", "Grp", "Player", "PlUnits",
                       "AllUnits". Anything else searches nothing. (default: "")

Returns:
    OBJECT, GROUP, or false when nothing matches.

Author:
    Mr H. (original, MRHMilsimTools, ADPL-SA), ported by Ghost
---------------------------------------------------------------------------- */
params [["_string", "", [""]], ["_type", "", [""]]];

private _pool = switch (_type) do {
    case "Obj": {allMissionObjects "All"};
    case "Grp": {allGroups};
    case "Player": {allPlayers};
    case "PlUnits": {playableUnits};
    case "AllUnits": {allUnits};
    default {[]};
};

private _index = _pool findIf {str _x isEqualTo _string};
if (_index < 0) exitWith {false};

_pool select _index
