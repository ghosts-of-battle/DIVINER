#include "script_component.hpp"
/*
    File: fnc_opordDef.sqf
    Author: YonV
    Description: What an operation order holds - the sections and their
        fields, in order.

        THE UNIT'S OWN LIST WHEN THERE IS ONE: <unit>.system.opord, edited on
        the website's Templates > System page, reaches every machine as
        GVAR(opordDef) (the server reads it at boot, FUNC(boot) step 4).
        Without one, this is the shape the mod itself reads - FUNC(app),
        FUNC(opordPost) and FUNC(opordField) - so an order written in game
        on a server with no database is still an order the mod can post.

        Kinds: "t" one line, "x" a paragraph, "a" a list (one per line).

    Parameters:
        None

    Returns:
        [[sectionId, title, hint, [[fieldId, label, kind], ...]], ...] <ARRAY>
*/

private _rows = missionNamespace getVariable [QGVAR(opordDef), []];
if (_rows isEqualType [] && {count _rows > 0}) exitWith {
    // the flat rows the website keeps, folded into sections in their order
    private _out = [];
    {
        private _r = _x;
        if !(_r isEqualType createHashMap) then {continue};
        private _sec = _r getOrDefault ["section", ""];
        private _fid = _r getOrDefault ["field", ""];
        if (_sec isEqualTo "" || _fid isEqualTo "") then {continue};
        private _at = _out findIf {(_x # 0) isEqualTo _sec};
        if (_at < 0) then {
            _out pushBack [_sec, _r getOrDefault ["sectionTitle", _sec], _r getOrDefault ["sectionHint", ""], []];
            _at = (count _out) - 1;
        };
        private _kind = _r getOrDefault ["kind", "x"];
        if !(_kind in ["t", "a", "x"]) then {_kind = "x"};
        ((_out # _at) # 3) pushBack [_fid, _r getOrDefault ["label", _fid], _kind];
    } forEach _rows;
    _out
};

[
    ["header", "Header", "Who this is for, and when", [
        ["id", "Order id", "t"], ["title", "Title", "t"], ["date", "Date", "t"], ["campaign", "Campaign", "t"],
        ["release", "Release", "t"], ["distribution", "Distribution", "t"], ["mapImage", "Map image", "t"], ["markers", "Markers", "a"]
    ]],
    ["situation", "Situation", "What is going on", [
        ["overview", "Overview", "x"], ["enemy", "Enemy", "x"], ["enemyFactions", "Enemy factions", "a"],
        ["friendly", "Friendly", "x"], ["civilTerrain", "Civil / terrain", "x"]
    ]],
    ["mission", "Mission", "What we are doing", [
        ["mission", "Mission", "x"], ["execution", "Execution", "x"]
    ]],
    ["adminLogistics", "Admin / logistics", "How we are supported", [
        ["admin", "Admin", "x"], ["logistics", "Logistics", "x"], ["special", "Special", "x"], ["armaConsiderations", "Arma considerations", "x"]
    ]],
    ["commandSignal", "Command / signal", "Who is in charge and how we talk", [
        ["signal", "Signal", "x"], ["command", "Command", "x"]
    ]],
    ["roe", "ROE", "Rules of engagement", [
        ["roeText", "ROE", "x"], ["clarifications", "Clarifications", "a"]
    ]]
]
