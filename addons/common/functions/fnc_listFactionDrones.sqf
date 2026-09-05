#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_listFactionDrones

Description:
    Feeder for the Eden faction dropdown (ghost_DroneFactionChoice), which lists
    only the factions that actually own drones. Returns the UAV / UGV
    CfgVehicles classes belonging to a faction, as display rows.

    A "drone" is any scope==2 CfgVehicles class with isUav > 0 (covers both
    unmanned air vehicles and UGVs). Category is "air" for anything kindOf
    "Air", otherwise "ground". Faction match is case-insensitive against the
    class's `faction` property; passing "" (or "ALL") returns every drone
    across all factions so the picker is never empty before a faction is set.

Parameters:
    _faction : STRING - faction classname to filter to, or "" / "ALL" for all.

Returns:
    ARRAY of [class, display, side, category, sourceMod]
        class      : STRING - CfgVehicles classname
        display    : STRING - displayName (falls back to classname)
        side       : NUMBER - getNumber side (0/1/2/3, -1 if absent)
        category   : STRING - "air" | "ground"
        sourceMod  : STRING - owning mod tag (first configSourceModList entry)

Author:
    Ghost
---------------------------------------------------------------------------- */

params [["_faction", "", [""]]];
private _facLower = toLower _faction;
private _all = (_facLower == "" || _facLower == "all");

// Engine-filtered pass: scope 2 + isUav. Cheap; keeps the SQF loop small.
// not the autonomous turrets, SAM sites and radars - they carry isUav too
private _cands = "getNumber (_x >> 'scope') == 2 && {getNumber (_x >> 'isUav') > 0} && {!((configName _x) isKindOf 'StaticWeapon')}" configClasses (configFile >> "CfgVehicles");

private _rows = [];
{
    private _cfg = _x;
    private _cn  = configName _cfg;
    private _fac = toLower getText (_cfg >> "faction");
    if (_all || _fac == _facLower) then {
        private _dn = getText (_cfg >> "displayName");
        if (_dn == "") then { _dn = _cn };
        private _side = if (isNumber (_cfg >> "side")) then { getNumber (_cfg >> "side") } else { -1 };
        private _cat = ["ground", "air"] select (_cn isKindOf "Air");
        private _src = (configSourceModList _cfg) param [0, "A3"];
        _rows pushBack [_cn, _dn, _side, _cat, _src];
    };
} forEach _cands;

_rows
