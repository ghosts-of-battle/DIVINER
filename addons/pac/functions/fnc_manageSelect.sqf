#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_manageSelect

Description:
    The management list's onLBSelChanged: puts the selected item into the
    ID and field edits. ORBAT items are filled from the structure this
    machine holds; an operator's file is asked of the server
    (FUNC(adminGet)) and filled when it arrives (FUNC(manageFill)); a log
    line is shown whole in the hint.

Parameters:
    None

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

disableSerialization;
private _display = uiNamespace getVariable [QGVAR(manageDisplay), displayNull];
if (isNull _display) exitWith {};

private _list = _display displayCtrl PAC_IDC_MG_LIST;
private _sel = lbCurSel _list;
if (_sel < 0) exitWith {};

private _key = _list lbData _sel;
GVAR(mgKey) = _key;
private _section = GVAR(mgSection);

private _fnc_put = {
    // values by field name, into the six edits, arrays comma-joined
    params ["_values"];
    {
        _x params ["_editIdc", "_i"];
        ((GVAR(mgFields) # _i) params ["", "_field"]);
        private _v = if (_field isEqualTo "") then {""} else {_values getOrDefault [_field, ""]};
        if (_v isEqualType []) then {_v = _v joinString ", "};
        if !(_v isEqualType "") then {_v = str _v};
        (_display displayCtrl _editIdc) ctrlSetText _v;
    } forEach [[PAC_IDC_MG_F1, 0], [PAC_IDC_MG_F2, 1], [PAC_IDC_MG_F3, 2], [PAC_IDC_MG_F4, 3], [PAC_IDC_MG_F5, 4], [PAC_IDC_MG_F6, 5]];
};

private _orbat = if (!isNil "ghostD_groups_fnc_orbat") then {[] call ghostD_groups_fnc_orbat} else {[[], [], [], ""]};
(_display displayCtrl PAC_IDC_MG_ID) ctrlSetText _key;

switch (_section) do {
    case "log": {
        private _row = GVAR(logRows) select {(_x # 0) isEqualTo _key};
        if (_row isEqualTo []) exitWith {};
        (_row # 0) params [["_id", ""], ["_when", ""], ["_byUid", ""], ["_byName", ""], ["_type", ""], ["_targetUid", ""], ["_target", ""], ["_detail", ""]];
        (_display displayCtrl PAC_IDC_MG_HINT) ctrlSetStructuredText parseText format [
            "<t size='0.8'><t font='RobotoCondensedBold'>%1</t>   %2<br/><br/>by  <t font='RobotoCondensedBold'>%3</t>  (%4)<br/>type  <t font='RobotoCondensedBold'>%5</t><br/>on  <t font='RobotoCondensedBold'>%6</t>  %7<br/><br/>%8</t>",
            _id, _when, _byName, _byUid, _type, [_target, "-"] select (_target isEqualTo ""), _targetUid, _detail
        ];
    };
    case "squads": {
        private _rows = _orbat # 0;
        private _at = _rows findIf {toUpper (_x # 0) isEqualTo toUpper _key};
        if (_at < 0) exitWith {};
        (_rows # _at) params ["_name", "_roles", ["_cond", "true"]];
        [createHashMapFromArray [["name", _name], ["roles", _roles], ["condition", _cond], ["position", _at + 1]]] call _fnc_put;
    };
    case "platoons": {
        private _rows = _orbat # 1;
        private _at = _rows findIf {(_x # 0) isEqualTo _key};
        if (_at < 0) exitWith {};
        (_rows # _at) params ["", "_name", "_callsign", "_net", "_squads"];
        [createHashMapFromArray [["name", _name], ["callsign", _callsign], ["net", _net], ["squads", _squads]]] call _fnc_put;
    };
    case "radionets": {
        private _rows = _orbat # 2;
        private _at = _rows findIf {(_x # 0) isEqualTo _key};
        if (_at < 0) exitWith {};
        (_rows # _at) params ["", "_net", "_squads"];
        [createHashMapFromArray [["net", _net], ["squads", _squads]]] call _fnc_put;
    };
    case "faction": {
        [createHashMapFromArray [
            ["name", _orbat param [3, ""]],
            ["side", _orbat param [4, "WEST"]]
        ]] call _fnc_put;
    };
    // The channels come off the live radio globals, which is what the mod is
    // actually using - not off a document that may be a boot behind.
    case "squadradio": {
        private _acre = "";
        {
            if (toUpper (_x param [0, ""]) isEqualTo toUpper _key) exitWith {_acre = str (_x param [1, 0])};
        } forEach (missionNamespace getVariable ["ghostFR_radio_srSquadChannel", []]);
        private _sw = "";
        private _lr = "";
        {
            if (toUpper (_x param [0, ""]) isEqualTo toUpper _key) exitWith {
                _sw = str (_x param [1, 0]);
                _lr = str (_x param [2, 0]);
            };
        } forEach (missionNamespace getVariable ["ghostFR_radio_tfarNets", []]);
        [createHashMapFromArray [["acre", _acre], ["tfarSw", _sw], ["tfarLr", _lr]]] call _fnc_put;
    };
    case "platoonradio": {
        private _ch = "";
        {
            if (toUpper (_x param [0, ""]) isEqualTo toUpper _key) exitWith {_ch = str (_x param [1, 0])};
        } forEach (missionNamespace getVariable ["ghostFR_radio_lrPlatoonChannel", []]);
        [createHashMapFromArray [["lr", _ch]]] call _fnc_put;
    };
    case "operators": {
        GVAR(editUid) = _key;
        GVAR(editRecord) = createHashMap;
        [] call FUNC(manageFill);
        [player, _key] remoteExec [QFUNC(adminGet), 2];
    };
};
