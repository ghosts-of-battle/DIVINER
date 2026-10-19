#include "script_component.hpp"
/*
    File: fnc_pgOpordDef.sqf
    Author: YonV
    Description: What an operation order holds - the sections and fields
        the order editor draws (FUNC(opordDef)). Read here; edited on the
        website's Templates > System, which writes <unit>.system.opord.

    Parameters:
        None

    Returns:
        Nothing
*/

GVAR(uiLive) = true;
private _def = [] call FUNC(opordDef);
private _fromDb = (missionNamespace getVariable [QGVAR(opordDef), []]) isNotEqualTo [];
["Operation order sections", format ["Templates  -  System  -  %1", ["the mod's own shape - no <unit>.system.opord document", (GVAR(settings) getOrDefault ["unitId", ""]) + ".system.opord"] select _fromDb]] call FUNC(uiTitle);

private _rows = [];
{
    _x params ["_sec", "_title", "_hint", "_fields"];
    _rows pushBack [[_sec, _title, _hint, "", ""], "", [0.576, 0.812, 0.447, 1]];
    {
        _x params ["_fid", "_label", "_kind"];
        _rows pushBack [["", format ["    %1.%2", _sec, _fid], _label, switch (_kind) do {case "t": {"one line"}; case "a": {"a list"}; default {"paragraph"}}, ""], ""];
    } forEach _fields;
} forEach _def;
[PAC_IDC_LIST, ["Section", "Field", "Label", "Kind", ""], [0, 0.18, 0.46, 0.76, 0.9], _rows, {}, PAC_UI_TOP, PAC_UI_BOTTOM - PAC_UI_TOP - 0.06] call FUNC(uiList);
["Sections and fields are edited on the website (Templates, System). The order editor here and the tacpad read whatever that says; without a document, the shape above is the mod's own.", PAC_UI_BOTTOM - 0.056, 0.056, "", PAC_UI_X, PAC_UI_W, true] call FUNC(uiText);
