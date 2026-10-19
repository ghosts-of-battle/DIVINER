#include "script_component.hpp"
/*
    File: fnc_pgBackup.sqf
    Author: YonV
    Description: Backup - the website's ?page=backup, done the way a game
        can: the store and the structure out to the clipboard as JSON, and
        back in from it. What the website keeps on its own disk the game
        cannot read; what the game keeps (the profile store) the website
        cannot.

    Parameters:
        None

    Returns:
        Nothing
*/

GVAR(uiLive) = true;
private _sum = missionNamespace getVariable [QGVAR(summary), createHashMap];
["Backup", "The store and the structure, out to your clipboard and back in from it"] call FUNC(uiTitle);

private _savedAt = _sum getOrDefault ["savedAt", ""];
private _kv = [
    ["Store", _sum getOrDefault ["backend", "profile"]],
    ["Game last wrote it", [_savedAt, "never this mission - it writes on SAVE THE STORE, or at mission end"] select (_savedAt isEqualTo "")],
    ["Read only", ["no", "YES"] select (_sum getOrDefault ["readOnly", false])],
    ["Operators in it", str (_sum getOrDefault ["players", 0])],
    ["Sessions", str (_sum getOrDefault ["sessions", 0])],
    ["Operation windows", str (_sum getOrDefault ["windows", 0])],
    ["Structure hash", if ((_sum getOrDefault ["hash", 0]) isEqualType 0) then {(_sum getOrDefault ["hash", 0]) toFixed 0} else {str (_sum getOrDefault ["hash", ""])}]
];
private _kvH = 0.028 + (count _kv) * 0.032;
[PAC_IDC_LIST, [], [0, 0.30], _kv apply {[_x, ""]}, {}, PAC_UI_TOP, _kvH, "What there is"] call FUNC(uiList);

private _rows = [
    [["EXPORT THE STORE", "the whole store as JSON - players, sessions, windows, the log - to your clipboard and the .rpt"], ""],
    [["IMPORT (MERGE)", "JSON on your clipboard merged in: per record the newer updatedAt wins, unseen sessions and windows are added"], ""],
    [["RESTORE", "JSON on your clipboard REPLACES the store"], ""],
    [["STRUCTURE OUT", "ranks, skills, roles, the ORBAT, every config - as JSON, to your clipboard"], ""],
    [["STRUCTURE IN", "JSON on your clipboard replaces the structure"], ""],
    [["EXPORT CLASSES", "every weapon, magazine, item, backpack and vehicle this server has loaded, to the database, so the website's editors can offer real classnames"], ""]
];
[PAC_IDC_LIST2, ["Button", "What it does"], [0, 0.20], _rows, {}, PAC_UI_TOP + _kvH + 0.012, PAC_UI_BOTTOM - PAC_UI_TOP - _kvH - 0.012, "The buttons along the foot"] call FUNC(uiList);

[[
    ["EXPORT THE STORE", {
        [player, "export", ""] remoteExec [QFUNC(adminText), 2];
        ["On its way to your clipboard and the .rpt.", false] call FUNC(uiHint);
    }],
    ["IMPORT (MERGE)", {
        ["Merge the JSON on your clipboard into the store?", {
            private _text = copyFromClipboard;
            if (_text isEqualTo "") exitWith {["The clipboard is empty.", true] call FUNC(uiHint)};
            [player, _text, "merge"] remoteExec [QFUNC(import), 2];
        }] call FUNC(uiConfirm);
    }],
    ["RESTORE", {
        ["REPLACE the store with the JSON on your clipboard? Every record, session and window not in it is gone.", {
            private _text = copyFromClipboard;
            if (_text isEqualTo "") exitWith {["The clipboard is empty.", true] call FUNC(uiHint)};
            [player, _text, "restore"] remoteExec [QFUNC(import), 2];
        }] call FUNC(uiConfirm);
    }, true],
    ["STRUCTURE OUT", {
        [player, "structure", ""] remoteExec [QFUNC(adminText), 2];
        ["On its way to your clipboard and the .rpt.", false] call FUNC(uiHint);
    }],
    ["STRUCTURE IN", {
        ["Replace the structure with the JSON on your clipboard? Ranks, skills, roles, the ORBAT - all of it.", {
            private _text = copyFromClipboard;
            if (_text isEqualTo "") exitWith {["The clipboard is empty.", true] call FUNC(uiHint)};
            [player, _text] remoteExec [QFUNC(structureImport), 2];
        }] call FUNC(uiConfirm);
    }, true],
    ["EXPORT CLASSES", {
        ["Write this server's loaded classnames to the database (<unit>.classes)?", {
            [player] remoteExec [QFUNC(exportClasses), 2];
            ["Exporting ...", false] call FUNC(uiHint);
        }] call FUNC(uiConfirm);
    }]
]] call FUNC(uiButtons);
