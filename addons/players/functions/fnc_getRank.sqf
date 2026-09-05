#include "script_component.hpp"
/*
    File: fn_player_getRank.sqf
    Author: YonV
    Description: Returns a player's engine rank: the live Steam-id map (YMF_playerRanks,
        seeded from a mission's Dynamic_Ranks if it still carries one), else Private.
        TAC//PAC's rank ladder is the unit's real one and goes on the man after this.

    Arguments:
    0: Unit or Steam UID <OBJECT|STRING>
    1: Style <STRING> (Default: "BIS") - "BIS" returns the engine rank name ("Sergeant"),
        "USA" returns the short US style ("SGT")

    Example:
    [player, 'BIS'] call ghostD_players_fnc_getRank;
*/

params [
    ["_unit", objNull, [objNull,""]],
    ["_style", "BIS", [""]]
];

private _uid = if (_unit isEqualType "") then {_unit} else {getPlayerUID _unit};
// THE FLOOR IS PRIVATE. A mission may still say otherwise in Dynamic_Ranks >>
// default_rank; a unit whose ranks live in TAC//PAC carries no such class,
// and TAC//PAC puts the man's real rank on him after this (applyRank).
private _default = getText (missionConfigFile >> "Dynamic_Ranks" >> "default_rank");
if (_default isEqualTo "") then {_default = "Private"};
private _rank = (missionNamespace getVariable ["YMF_playerRanks",createHashMap]) getOrDefault [_uid, _default];

if (toUpper _style isEqualTo "USA") exitWith {
    switch (toUpper _rank) do {
        case "PRIVATE": {"PVT"};
        case "CORPORAL": {"CPL"};
        case "SERGEANT": {"SGT"};
        case "LIEUTENANT": {"LT"};
        case "CAPTAIN": {"CPT"};
        case "MAJOR": {"MAJ"};
        case "COLONEL": {"COL"};
        default {_rank};
    }
};

_rank
