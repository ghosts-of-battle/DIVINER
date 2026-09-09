#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_rankOf

Description:
    A player's PAC rank as an Arma rank name, in the proper case the players
    addon uses ("Sergeant") - or "" when PAC has nothing for them: no roster
    row, no rank on the record, or a rank whose armaRank is not one of the
    seven.

    READ ON ANY MACHINE, off the published roster and the structure every
    client holds. ghostD_players_fnc_getRank calls this so that PAC is the
    source of truth for rank everywhere the engine rank is looked up -
    setRank (the login, the role setup, the arsenal), the role gates, the
    admin panel's list and combo. Without it every one of those put the
    mission's floor back over the PAC rank (user, 2026-09-05: "admin panel
    still shows me as a pvt - needs to match pac at login or at role or
    arsenal open").

Parameters:
    0: Unit, or Steam id <OBJECT|STRING>

Returns:
    "Private" .. "Colonel", or "" <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_who", "", [objNull, ""]]];

private _uid = if (_who isEqualType "") then {_who} else {[_who] call FUNC(uid)};
if (_uid isEqualTo "") exitWith {""};

private _row = (missionNamespace getVariable [QGVAR(roster), []]) select {(_x # 0) isEqualTo _uid};
if (_row isEqualTo []) exitWith {""};

private _rankId = (_row # 0) param [2, ""];
if !(_rankId isEqualType "" && _rankId isNotEqualTo "") exitWith {""};

private _rank = (GVAR(structure) getOrDefault ["ranks", createHashMap]) getOrDefault [_rankId, createHashMap];
if !(_rank isEqualType createHashMap) exitWith {""};

private _proper = ["Private", "Corporal", "Sergeant", "Lieutenant", "Captain", "Major", "Colonel"];
private _i = (_proper apply {toUpper _x}) find (toUpper (_rank getOrDefault ["armaRank", ""]));
if (_i < 0) exitWith {""};

_proper select _i
