#include "script_component.hpp"
/*
    File: fnc_pgRoster.sqf
    Author: YonV
    Description: The roster - the website's ?page=roster: one row an
        operator, the same columns, a name is a link to their page.

    Parameters:
        None

    Returns:
        Nothing
*/

GVAR(uiLive) = true;
private _roster = missionNamespace getVariable [QGVAR(roster), []];
["Roster", format ["%1 operator(s)  -  the game overwrites the store when an admin presses SAVE THE STORE", count _roster]] call FUNC(uiTitle);
private _f = [] call FUNC(uiFilterShow);

private _rows = [];
{
    _x params ["_uid", "_name", "_rankId", "_roleId", "_groupId", "_statusId", "_skillIds", "", "_updated", "", ["_opId", ""], ["_discord", false]];
    private _rank = ["ranks", _rankId, "abbrev"] call FUNC(lookup);
    private _role = ["roles", _roleId] call FUNC(lookup);
    private _status = ["statuses", _statusId] call FUNC(lookup);
    if (_f isNotEqualTo "" && {!(_f in toLower ([_name, _rank, _role, _groupId, _status, _opId] joinString " "))}) then {continue};
    _rows pushBack [[
        _opId, _name, _rank, _role, _groupId, _status,
        ["unlinked", "linked"] select _discord,
        str (count _skillIds), _updated select [0, 10]
    ], _uid];
} forEach _roster;

[PAC_IDC_LIST, ["Operator", "Name", "Rank", "Role", "Group", "Status", "Discord", "Skills", "Updated"],
    [0, 0.09, 0.30, 0.37, 0.52, 0.63, 0.72, 0.80, 0.88], _rows, {
    params ["_uid"];
    ["player", createHashMapFromArray [["uid", _uid]]] call FUNC(uiGo);
}, PAC_UI_TOP, PAC_UI_BOTTOM - PAC_UI_TOP] call FUNC(uiList);

[[
    ["ADD AN OPERATOR", {["addOperator"] call FUNC(uiGo)}],
    ["IMPORT CSV", {
        ["Import pac_roster.csv from the mission folder? Rows update or create records.", {
            [player, "pac_roster.csv"] remoteExec [QFUNC(csvImport), 2];
        }] call FUNC(uiConfirm);
    }]
]] call FUNC(uiButtons);
