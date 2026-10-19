#include "script_component.hpp"
/*
    File: fnc_pgConfigs.sqf
    Author: YonV
    Description: Configs - the website's ?page=records: one row a document
        (ranks, skills, awards, statuses, promotion, trainings, settings,
        admins), with its Mongo doc name and how many it holds. A row opens
        the list.

    Parameters:
        None

    Returns:
        Nothing
*/

GVAR(uiLive) = true;
["Configs", "The documents a unit is made of. Each replaces a file in the mission's config folder."] call FUNC(uiTitle);
private _unit = GVAR(settings) getOrDefault ["unitId", ""];

private _rows = ["ranks", "skills", "awards", "statuses", "promotion", "trainings", "settings", "admins"] apply {
    ([_x] call FUNC(uiSectionLabel)) params ["_label", "_blurb"];
    private _n = count ([_x] call FUNC(structItems));
    private _fed = [_x] call FUNC(fileFed);
    [[_label, _unit + "." + _x, str _n, [_blurb, "from the mission's config folder - read only in game"] select _fed], _x]
};
[PAC_IDC_LIST, ["Config", "Mongo doc", "Entries", ""], [0, 0.18, 0.40, 0.48], _rows, {
    params ["_sec"];
    ["record", createHashMapFromArray [["sec", _sec]]] call FUNC(uiGo);
}, PAC_UI_TOP, PAC_UI_BOTTOM - PAC_UI_TOP] call FUNC(uiList);
