#include "script_component.hpp"
/*
    File: fnc_pgRadioChannels.sqf
    Author: YonV
    Description: A radio band's channels - the website's ACRE / TFAR
        tables. ACRE: index, frequency, label (and power on long range),
        one row a channel; click a row to edit it, ADD for a new one,
        SAVE writes the table. TFAR: the eight channels' short and long
        range frequencies.

        The working copy is GVAR(uiRadioRows) until SAVE - what is on
        screen is what SAVE sends.

    Parameters:
        None - reads GVAR(uiArgs): band ("sr" | "mr" | "lr" | "tfar"), pick

    Returns:
        Nothing
*/

private _band = GVAR(uiArgs) getOrDefault ["band", "sr"];
private _pick = GVAR(uiArgs) getOrDefault ["pick", -1];
private _radio = GVAR(structure) getOrDefault ["radio", createHashMap];
private _unit = GVAR(settings) getOrDefault ["unitId", ""];
private _fed = ["radio"] call FUNC(fileFed);
private _tfar = _band isEqualTo "tfar";
private _key = switch (_band) do {case "mr": {"mrChannels"}; case "lr": {"lrChannels"}; case "tfar": {"tfarSrFreqs"}; default {"srChannels"}};
private _title = switch (_band) do {case "mr": {"Medium range channels"}; case "lr": {"Long range channels"}; case "tfar": {"TFAR channels"}; default {"Short range channels"}};

// the working copy, fresh when the band changes
if (isNil QGVAR(uiRadioRows) || {(missionNamespace getVariable [QGVAR(uiRadioKey), ""]) isNotEqualTo _band}) then {
    if (_tfar) then {
        private _sw = _radio getOrDefault ["tfarSrFreqs", []];
        private _lr = _radio getOrDefault ["tfarLrFreqs", []];
        if !(_sw isEqualType []) then {_sw = []};
        if !(_lr isEqualType []) then {_lr = []};
        GVAR(uiRadioRows) = [];
        for "_i" from 0 to 7 do {GVAR(uiRadioRows) pushBack [_i + 1, str (_sw param [_i, ""]), str (_lr param [_i, ""])]};
    } else {
        private _rows = _radio getOrDefault [_key, []];
        if !(_rows isEqualType []) then {_rows = []};
        GVAR(uiRadioRows) = +(_rows select {_x isEqualType []});
    };
    GVAR(uiRadioKey) = _band;
};
private _rows = GVAR(uiRadioRows);

[_title, format ["ORBAT  -  Communications  -  %1.radio  -  %2%3", _unit, [_key, "tfarSrFreqs / tfarLrFreqs"] select _tfar, ["", "  -  from the config folder, read only in game"] select _fed]] call FUNC(uiTitle);

private _listRows = [];
{
    if (_tfar) then {
        _listRows pushBack [[str (_x # 0), _x param [1, ""], _x param [2, ""]], str _forEachIndex];
    } else {
        _listRows pushBack [[str (_x param [0, ""]), str (_x param [1, ""]), _x param [2, ""], [str (_x param [3, ""]), ""] select (_band isNotEqualTo "lr")], str _forEachIndex];
    };
} forEach _rows;
if (_listRows isEqualTo []) then {_listRows = [[["No channels", "", "", ""], "", [0.545, 0.592, 0.639, 1]]]};
private _listH = PAC_UI_BOTTOM - PAC_UI_TOP - 0.150;
[PAC_IDC_LIST, [["Index", "Frequency", "Label", "Power"], ["Channel", "Short range frequency", "Long range frequency"]] select _tfar, [[0, 0.12, 0.30, 0.70], [0, 0.16, 0.50]] select _tfar, _listRows, {
    params ["_i"];
    if (_i isEqualTo "") exitWith {};
    private _a = +GVAR(uiArgs);
    _a set ["pick", parseNumber _i];
    ["radioChannels", _a] call FUNC(uiSub);
}, PAC_UI_TOP, _listH, format ["%1  %2  -  click a row to edit it", _title, count _rows]] call FUNC(uiList);

private _row = if (_pick >= 0 && _pick < count _rows) then {_rows # _pick} else {[]};
private _formRows = if (_tfar) then {[
    ["index", "Channel", "r", str ((_row param [0, 0]))],
    ["sw", "Short range frequency", "t", _row param [1, ""]],
    ["lr", "Long range frequency", "t", _row param [2, ""]]
]} else {[
    ["index", "Index", "n", _row param [0, (count _rows) + 1]],
    ["freq", "Frequency", "n", _row param [1, 0]],
    ["label", "Label", "t", _row param [2, ""]]
] + ([[], [["power", "Power", "n", _row param [3, 0]]]] select (_band isEqualTo "lr"))};
[_formRows, PAC_UI_TOP + _listH + 0.008, PAC_UI_X, PAC_UI_W / 2] call FUNC(uiForm);

if (_fed) exitWith {[[]] call FUNC(uiButtons)};
private _btns = [
    [["SET CHANNEL", "SET"] select _tfar, {
        private _f = [] call FUNC(uiFormRead);
        private _pick = GVAR(uiArgs) getOrDefault ["pick", -1];
        private _band = GVAR(uiArgs) getOrDefault ["band", "sr"];
        if (_band isEqualTo "tfar") exitWith {
            if (_pick < 0) exitWith {["Click a channel first.", true] call FUNC(uiHint)};
            GVAR(uiRadioRows) set [_pick, [_pick + 1, trim (_f getOrDefault ["sw", ""]), trim (_f getOrDefault ["lr", ""])]];
            [] call FUNC(uiDraw);
        };
        private _row = [_f getOrDefault ["index", 0], _f getOrDefault ["freq", 0], trim (_f getOrDefault ["label", ""])];
        if (_band isEqualTo "lr") then {_row pushBack (_f getOrDefault ["power", 0])};
        if (_pick >= 0 && _pick < count GVAR(uiRadioRows)) then {GVAR(uiRadioRows) set [_pick, _row]} else {GVAR(uiRadioRows) pushBack _row};
        private _a = +GVAR(uiArgs);
        _a set ["pick", -1];
        ["radioChannels", _a] call FUNC(uiSub);
    }],
    ["SAVE", {
        private _band = GVAR(uiArgs) getOrDefault ["band", "sr"];
        if (_band isEqualTo "tfar") exitWith {
            [player, "radio", "set", "tfarSrFreqs", createHashMapFromArray [["value", GVAR(uiRadioRows) apply {_x # 1}]]] remoteExec [QFUNC(adminOrbat), 2];
            [player, "radio", "set", "tfarLrFreqs", createHashMapFromArray [["value", GVAR(uiRadioRows) apply {_x # 2}]]] remoteExec [QFUNC(adminOrbat), 2];
            ["Saved.", false] call FUNC(uiHint);
        };
        private _key = switch (_band) do {case "mr": {"mrChannels"}; case "lr": {"lrChannels"}; default {"srChannels"}};
        [player, "radio", "set", _key, createHashMapFromArray [["value", +GVAR(uiRadioRows)]]] remoteExec [QFUNC(adminOrbat), 2];
        ["Saved.", false] call FUNC(uiHint);
    }]
];
if (!_tfar && _pick >= 0) then {
    _btns pushBack ["REMOVE CHANNEL", {
        private _pick = GVAR(uiArgs) getOrDefault ["pick", -1];
        if (_pick >= 0 && _pick < count GVAR(uiRadioRows)) then {GVAR(uiRadioRows) deleteAt _pick};
        private _a = +GVAR(uiArgs);
        _a set ["pick", -1];
        ["radioChannels", _a] call FUNC(uiSub);
    }, true];
};
[_btns] call FUNC(uiButtons);
