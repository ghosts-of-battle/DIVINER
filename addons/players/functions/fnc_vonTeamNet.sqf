#include "script_component.hpp"
/*
 * Author: YonV
 * The name of a squad's TEAM net - the label its Group channel carries under the
 * base-game voice (VON) plan.
 *
 * ghostFR_radio_vonTeamNets is [[squadName, teamNetName], ...]. A squad with no
 * row, or a blank name, is its own team net: the answer is the squad's name.
 *
 * Arguments:
 * 0: Squad name <STRING>
 *
 * Return Value:
 * Team net name <STRING>
 *
 * Example:
 * ["ALPHA"] call ghostD_players_fnc_vonTeamNet
 *
 * Public: No
 */

params [["_squad", "", [""]]];

private _rows = missionNamespace getVariable ["ghostFR_radio_vonTeamNets", []];
if !(_rows isEqualType []) then {_rows = []};

private _key = toUpper trim _squad;
private _at = _rows findIf {
    _x isEqualType [] && {(_x param [0, ""]) isEqualType ""} && {toUpper trim (_x param [0, ""]) isEqualTo _key}
};
if (_at < 0) exitWith {_squad};

private _name = (_rows # _at) param [1, ""];
if (!(_name isEqualType "") || {trim _name isEqualTo ""}) exitWith {_squad};

trim _name
