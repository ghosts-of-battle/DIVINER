#include "script_component.hpp"
/*
    File: fnc_pgOrbatOne.sqf
    Author: YonV
    Description: One order of battle - the website's ?page=orbat&s=one:
        faction and side, and what it runs (which nets, radio plan, arsenal
        and motorpool versions). The game holds only the version the
        mission runs; another version shows what it is and can be made the
        default.

    Parameters:
        None - reads GVAR(uiArgs): v ("" = Default)

    Returns:
        Nothing
*/

private _v = GVAR(uiArgs) getOrDefault ["v", ""];
private _unit = GVAR(settings) getOrDefault ["unitId", ""];
private _structure = GVAR(structure);
private _orbat = _structure getOrDefault ["orbat", createHashMap];
private _cur = GVAR(settings) getOrDefault ["currentOrbat", ""];
if !(_cur isEqualType "") then {_cur = ""};
private _isCur = _v isEqualTo _cur;
private _doc = _unit + ".orbat" + (["", "." + _v] select (_v isNotEqualTo ""));
private _fed = ["orbat"] call FUNC(fileFed);

[[_v, "Default"] select (_v isEqualTo ""), format ["ORBAT  -  Orders of battle  -  %1%2", _doc, ["", "  -  the one the mission runs"] select _isCur]] call FUNC(uiTitle);

if (!_isCur) exitWith {
    ["This is not the order of battle the mission runs, and the game holds only that one - its platoons and squads are in the database. Make it the default and the next boot reads it; open it under Mongo docs to see it as it stands.", PAC_UI_TOP, 0.10, "", PAC_UI_X, PAC_UI_W, true] call FUNC(uiText);
    private _btns = [
        ["MAKE IT THE DEFAULT", {
            [format ["Run %1 from the next boot?", GVAR(uiArgs) getOrDefault ["v", ""]], {
                [player, "currentOrbat", GVAR(uiArgs) getOrDefault ["v", ""]] remoteExec [QFUNC(adminSetting), 2];
                ["settings currentOrbat set - the next boot reads it.", false] call FUNC(uiHint);
            }] call FUNC(uiConfirm);
        }]
    ];
    if ("service" in ((missionNamespace getVariable [QGVAR(summary), createHashMap]) getOrDefault ["backend", ""])) then {
        _btns pushBack ["OPEN AS A MONGO DOC", {
            private _v = GVAR(uiArgs) getOrDefault ["v", ""];
            ["doc", createHashMapFromArray [["key", (GVAR(settings) getOrDefault ["unitId", ""]) + ".orbat" + (["", "." + _v] select (_v isNotEqualTo ""))]]] call FUNC(uiGo);
        }];
    };
    [_btns] call FUNC(uiButtons);
};

private _ars = keys ((_structure getOrDefault ["arsenal", createHashMap]) getOrDefault ["variants", createHashMap]);
_ars = _ars select {!((_x select [0, 4]) in ["plt_", "sqd_"]) && {(_x select [0, 5]) isNotEqualTo "role_"}};
_ars sort true;
private _mp = keys (_structure getOrDefault ["motorpoolVariants", createHashMap]);
_mp = _mp select {!((_x select [0, 4]) in ["plt_", "sqd_"])};
_mp sort true;
private _fnc_opts = {
    params ["_list", "_current"];
    private _out = [["", "Default"]] + (_list apply {[_x, _x]});
    if (_current isNotEqualTo "" && {!(_current in _list)}) then {_out pushBack [_current, _current + " - not loaded"]};
    _out
};
private _y = [[
    ["faction", "Faction", "t", _orbat getOrDefault ["faction", ""]],
    ["side", "Side", "c", _orbat getOrDefault ["side", "WEST"], [["WEST", "BLUFOR - WEST"], ["EAST", "OPFOR - EAST"], ["GUER", "INDEPENDENT - GUER"], ["CIV", "CIVILIAN - CIV"]]],
    ["netsVersion", "Messaging nets version  (blank = Default)", "t", _orbat getOrDefault ["netsVersion", ""]],
    ["radioVersion", "Radio plan version  (blank = Default)", "t", _orbat getOrDefault ["radioVersion", ""]],
    ["arsenalVersion", "Arsenal", "c", _orbat getOrDefault ["arsenalVersion", ""], [_ars, _orbat getOrDefault ["arsenalVersion", ""]] call _fnc_opts],
    ["motorpoolVersion", "Motorpool", "c", _orbat getOrDefault ["motorpoolVersion", ""], [_mp, _orbat getOrDefault ["motorpoolVersion", ""]] call _fnc_opts]
], PAC_UI_TOP] call FUNC(uiForm);

private _groups = _orbat getOrDefault ["groups", []];
private _platoons = _orbat getOrDefault ["platoons", []];
private _slots = 0;
{_slots = _slots + count (_x param [1, []])} forEach _groups;
[PAC_IDC_LIST, [], [0, 0.30], [
    [["Platoons", str (count _platoons)], ""],
    [["Squads", format ["%1, %2 slots", count _groups, _slots]], ""],
    [["Everybody in it", "audibleCoef, camouflageCoef, loadCoef, staminaDrainCoef are the website's; the game does not read them"], "", [0.545, 0.592, 0.639, 1]]
], {}, _y + 0.006, 0.14, "What is in it"] call FUNC(uiList);

if (_fed) exitWith {
    ["From the mission's config folder - read only in game.", _y + 0.16, 0.05, "", PAC_UI_X, PAC_UI_W, true] call FUNC(uiText);
};
[[
    ["SAVE", {
        private _f = [] call FUNC(uiFormRead);
        [player, "faction", "set", "", createHashMapFromArray [["name", trim (_f getOrDefault ["faction", ""])], ["side", _f getOrDefault ["side", "WEST"]]]] remoteExec [QFUNC(adminOrbat), 2];
        [player, "runs", "set", "", createHashMapFromArray [
            ["netsVersion", trim (_f getOrDefault ["netsVersion", ""])], ["radioVersion", trim (_f getOrDefault ["radioVersion", ""])],
            ["arsenalVersion", _f getOrDefault ["arsenalVersion", ""]], ["motorpoolVersion", _f getOrDefault ["motorpoolVersion", ""]]
        ]] remoteExec [QFUNC(adminOrbat), 2];
        ["Saved.", false] call FUNC(uiHint);
    }]
]] call FUNC(uiButtons);
