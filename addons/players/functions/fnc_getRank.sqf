#include "script_component.hpp"
/*
    File: fn_player_getRank.sqf
    Author: YonV
    Description: Returns a player's engine rank. TAC//PAC's answer first - the rank on
        the man's published record, mapped to one of Arma's seven (ghostD_pac_fnc_rankOf) -
        else the live Steam-id map (YMF_playerRanks, seeded from a mission's Dynamic_Ranks
        if it still carries one), else Private. PAC is the source of truth for rank;
        the map and the default are the floor for a man PAC has nothing for.

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

// TAC//PAC IS THE SOURCE OF TRUTH FOR RANK. A man on the published roster wears
// the rank the unit gave him; the map and the default above are the floor for
// everyone else. Without this, every caller of setRank - the login script, the
// role setup, the arsenal opening and closing - put the floor back over PAC's
// rank, and the admin panel, which reads this, showed him as a private for the
// rest of the op (user, 2026-09-05). The role gates read this too, so a PAC
// rank now opens the slots it should.
if (!isNil "ghostD_pac_fnc_rankOf") then {
    private _pac = [_unit] call ghostD_pac_fnc_rankOf;
    if (_pac isNotEqualTo "") then {_rank = _pac};
};

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
