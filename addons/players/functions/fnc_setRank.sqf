#include "script_component.hpp"
/*
    File: fn_player_setRank.sqf
    Author: YonV
    Description: Applies the player's BIS rank from the Steam ID rank config
        (config_ranks.hpp). Replaces the old profile-name rank system - the style
        argument is kept for call site compatibility and ignored.

    Example:
    [player, 'BIS'] call ghostD_players_fnc_setRank;
*/

params [
    ["_unit", objNull, [objNull]],
    ["_style", "BIS", [""]]
];

if (isNull _unit) exitWith {""};

private _rank = [_unit] call EFUNC(players,getRank);
if ((toUpper _rank) in ["PRIVATE","CORPORAL","SERGEANT","LIEUTENANT","CAPTAIN","MAJOR","COLONEL"]) then {
    _unit setRank _rank;
};

_unit setVariable [QEGVAR(Player,rank), _rank];
_rank
