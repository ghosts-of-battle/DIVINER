#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_windowName

Description:
    A name for a window id, in whichever of FUNC(windowCurrent)'s three shapes
    it is. Server only for manual ids (the rows are here); the other two are
    answered from the structure, which every machine has.

Parameters:
    0: Window id <STRING>

Returns:
    Name, "" for an empty id, the id itself if nothing better is known <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_id", "", [""]]];

if (_id isEqualTo "") exitWith {""};

private _parts = _id splitString ":";
switch (_parts # 0) do {
    case "cfg": {
        private _i = parseNumber (_parts # 1);
        private _entry = (GVAR(settings) getOrDefault ["opWindows", []]) param [_i, []];
        if (count _entry isEqualTo 3) exitWith {
            format ["%1 %2-%3 (%4)", _entry # 0, _entry # 1, _entry # 2, _parts param [2, ""]]
        };
        if (count _entry isEqualTo 2) exitWith {
            format ["%1 to %2", _entry # 0, _entry # 1]
        };
        _id
    };
    case "opord": {
        private _opordId = (_parts select [1]) joinString ":";
        private _opord = (GVAR(structure) getOrDefault ["opords", createHashMap]) getOrDefault [_opordId, createHashMap];
        if (count _opord isEqualTo 0) then {_opord = (missionNamespace getVariable [QGVAR(opordArchive), createHashMap]) getOrDefault [_opordId, createHashMap]};
        private _header = _opord getOrDefault ["header", createHashMap];
        private _title = _header getOrDefault ["title", ""];
        ["OPORD " + _opordId, _title] select (_title isNotEqualTo "")
    };
    default {
        private _name = _id;
        {
            if ((_x # 0) isEqualTo _id) exitWith {_name = _x # 1};
        } forEach GVAR(windows);
        _name
    };
};
