#include "script_component.hpp"
/*
    File: fnc_pgPlatoon.sqf
    Author: YonV
    Description: One platoon - the website's ?page=platoon and its
        sections: IDENTITY, SQUADS, RADIO, ARSENAL, MOTORPOOL. A platoon is
        a row of the ORBAT's platoons - [id, name, callsign, net, squads] -
        and every save is one FUNC(adminOrbat) "platoon" set.

    Parameters:
        None - reads GVAR(uiArgs): id ("" + s "new" = new), s

    Returns:
        Nothing
*/

private _id = GVAR(uiArgs) getOrDefault ["id", ""];
private _s = GVAR(uiArgs) getOrDefault ["s", "identity"];
private _unit = GVAR(settings) getOrDefault ["unitId", ""];
private _structure = GVAR(structure);
private _orbat = _structure getOrDefault ["orbat", createHashMap];
private _platoons = _orbat getOrDefault ["platoons", []];
private _groups = _orbat getOrDefault ["groups", []];
private _radio = _structure getOrDefault ["radio", createHashMap];
private _fed = ["orbat"] call FUNC(fileFed);
private _at = _platoons findIf {(_x # 0) isEqualTo _id};

if (_s isEqualTo "new" || _at < 0) exitWith {
    ["New platoon", "ORBAT  -  Platoons"] call FUNC(uiTitle);
    [[
        ["id", "Id  (BANSHEE, 1PLT)", "t", _id],
        ["name", "Shown as", "t", ""]
    ], PAC_UI_TOP] call FUNC(uiForm);
    if (_fed) exitWith {};
    [[["CREATE IT", {
        private _f = [] call FUNC(uiFormRead);
        private _id = trim (_f getOrDefault ["id", ""]);
        if (_id isEqualTo "") exitWith {["A platoon needs an id.", true] call FUNC(uiHint)};
        [player, "platoon", "set", "", createHashMapFromArray [["id", _id], ["name", trim (_f getOrDefault ["name", ""])], ["callsign", ""], ["net", ""], ["squads", []]]] remoteExec [QFUNC(adminOrbat), 2];
        GVAR(uiHistory) deleteAt ((count GVAR(uiHistory)) - 1);
        ["platoon", createHashMapFromArray [["id", _id]]] call FUNC(uiGo);
    }]]] call FUNC(uiButtons);
};

(_platoons # _at) params [["_pid", ""], ["_name", ""], ["_callsign", ""], ["_net", ""], ["_squads", []]];
[[_name, _pid] select (_name isEqualTo ""), format ["ORBAT  -  Platoons  -  %1.orbat  -  %2 squad(s)%3", _unit, count _squads, ["", "  -  from the config folder, read only in game"] select _fed]] call FUNC(uiTitle);
[[
    ["IDENTITY", "identity"], ["SQUADS", "squads"], ["RADIO", "radio"], ["ARSENAL", "arsenal"], ["MOTORPOOL", "motorpool"]
], _s, {
    params ["_sec"];
    ["platoon", createHashMapFromArray [["id", GVAR(uiArgs) get "id"], ["s", _sec]]] call FUNC(uiSub);
}] call FUNC(uiSubs);

private _h = PAC_UI_BOTTOM - PAC_UI_TOP;
private _btns = [];
private _slug = "plt_" + ([_pid] call FUNC(uiSlug));

switch (_s) do {
    case "identity": {
        private _nets = [["", "- none -"]];
        {_nets pushBack [_x, format ["%1  %2", _x, _y getOrDefault ["name", ""]]]} forEach (_structure getOrDefault ["nets", createHashMap]);
        if (_net isNotEqualTo "" && {!(_net in (_structure getOrDefault ["nets", createHashMap]))}) then {_nets pushBack [_net, _net + "  (no such net)"]};
        [[
            ["id", "Id", "r", _pid],
            ["name", "Shown as", "t", _name],
            ["callsign", "Callsign", "t", _callsign],
            ["net", "Messaging net", "c", _net, _nets]
        ], PAC_UI_TOP] call FUNC(uiForm);
        if (!_fed) then {
            _btns pushBack ["SAVE IDENTITY", {
                private _f = [] call FUNC(uiFormRead);
                private _id = GVAR(uiArgs) get "id";
                private _platoons = (GVAR(structure) getOrDefault ["orbat", createHashMap]) getOrDefault ["platoons", []];
                private _at = _platoons findIf {(_x # 0) isEqualTo _id};
                if (_at < 0) exitWith {};
                [player, "platoon", "set", _id, createHashMapFromArray [["id", _id], ["name", trim (_f getOrDefault ["name", ""])], ["callsign", trim (_f getOrDefault ["callsign", ""])], ["net", _f getOrDefault ["net", ""]], ["squads", (_platoons # _at) param [4, []]]]] remoteExec [QFUNC(adminOrbat), 2];
                ["Saved.", false] call FUNC(uiHint);
            }];
            _btns pushBack ["DELETE PLATOON", {
                [format ["Delete the platoon %1? Its squads stay; they just belong to no platoon.", GVAR(uiArgs) get "id"], {
                    [player, "platoon", "remove", GVAR(uiArgs) get "id", createHashMap] remoteExec [QFUNC(adminOrbat), 2];
                    ["orbat", createHashMapFromArray [["s", "platoons"]]] call FUNC(uiGo);
                }] call FUNC(uiConfirm);
            }, true];
        };
    };

    case "squads": {
        private _choices = _groups apply {
            private _sq = _x # 0;
            private _elsewhere = (_platoons select {(_x # 0) isNotEqualTo _pid && {_sq in (_x param [4, []])}}) apply {_x param [1, _x # 0]};
            [_sq, _sq, ["", "already in " + (_elsewhere joinString ", ")] select (_elsewhere isNotEqualTo [])]
        };
        ["squads", _choices, _squads, PAC_IDC_LIST, PAC_UI_TOP, _h, format ["Squads in it  %1  -  click to tick", count _squads]] call FUNC(uiToggle);
        if (!_fed) then {
            _btns pushBack ["SAVE SQUADS", {
                private _id = GVAR(uiArgs) get "id";
                private _platoons = (GVAR(structure) getOrDefault ["orbat", createHashMap]) getOrDefault ["platoons", []];
                private _at = _platoons findIf {(_x # 0) isEqualTo _id};
                if (_at < 0) exitWith {};
                private _row = _platoons # _at;
                // keep the ORBAT's order, not the click order
                private _order = ((GVAR(structure) getOrDefault ["orbat", createHashMap]) getOrDefault ["groups", []]) apply {_x # 0};
                private _sel = GVAR(uiSel) getOrDefault ["squads", []];
                [player, "platoon", "set", _id, createHashMapFromArray [["id", _id], ["name", _row param [1, ""]], ["callsign", _row param [2, ""]], ["net", _row param [3, ""]], ["squads", _order select {_x in _sel}]]] remoteExec [QFUNC(adminOrbat), 2];
                ["Saved.", false] call FUNC(uiHint);
            }];
        };
    };

    case "radio": {
        private _rows = _radio getOrDefault ["lrPlatoonChannel", []];
        if !(_rows isEqualType []) then {_rows = []};
        private _mine = _rows select {_x isEqualType [] && {(_x param [0, ""]) isEqualTo _pid}};
        private _lr = _radio getOrDefault ["lrChannels", []];
        if !(_lr isEqualType []) then {_lr = []};
        private _opts = [["", "- the plan default -"]] + (_lr select {_x isEqualType []} apply {[str (_x param [0, 0]), format ["%1  %2  %3", _x param [0, ""], _x param [1, ""], _x param [2, ""]]]});
        [[["lr", "Long range channel", "c", [str ((_mine # 0) param [1, ""]), ""] select (_mine isEqualTo []), _opts]], PAC_UI_TOP] call FUNC(uiForm);
        ["Written to " + _unit + ".radio - lrPlatoonChannel, keyed by the platoon's id.", PAC_UI_TOP + 0.05, 0.05, "", PAC_UI_X, PAC_UI_W, true] call FUNC(uiText);
        if !(["radio"] call FUNC(fileFed)) then {
            _btns pushBack ["SAVE CHANNEL", {
                private _f = [] call FUNC(uiFormRead);
                [player, "platoonRadio", "set", GVAR(uiArgs) get "id", createHashMapFromArray [["lr", _f getOrDefault ["lr", ""]]]] remoteExec [QFUNC(adminOrbat), 2];
                ["Saved.", false] call FUNC(uiHint);
            }];
        };
    };

    case "arsenal": {
        private _own = ((_structure getOrDefault ["arsenal", createHashMap]) getOrDefault ["variants", createHashMap]) getOrDefault [_slug, createHashMap];
        [format ["This platoon's arsenal is %1.arsenal.%2 - %3. It is laid over the common arsenal for everybody in its squads.", _unit, _slug, [format ["%1 list(s)", count _own], "not written yet"] select (count _own isEqualTo 0)], PAC_UI_TOP, 0.08, "", PAC_UI_X, PAC_UI_W, true] call FUNC(uiText);
        _btns pushBack ["OPEN PLATOON ARSENAL", {["arsenalLists", createHashMapFromArray [["v", "plt_" + ([GVAR(uiArgs) get "id"] call FUNC(uiSlug))]]] call FUNC(uiGo)}];
    };

    case "motorpool": {
        private _own = (_structure getOrDefault ["motorpoolVariants", createHashMap]) getOrDefault [_slug, createHashMap];
        [format ["This platoon's motorpool is %1.motorpool.%2 - %3.", _unit, _slug, [format ["%1 heading(s)", count _own], "not written yet"] select (count _own isEqualTo 0)], PAC_UI_TOP, 0.08, "", PAC_UI_X, PAC_UI_W, true] call FUNC(uiText);
        _btns pushBack ["OPEN PLATOON MOTORPOOL", {["record", createHashMapFromArray [["sec", "motorpool"], ["v", "plt_" + ([GVAR(uiArgs) get "id"] call FUNC(uiSlug))]]] call FUNC(uiGo)}];
    };
};
[_btns] call FUNC(uiButtons);
