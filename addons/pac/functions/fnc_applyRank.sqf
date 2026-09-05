#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_applyRank

Description:
    Puts a player's PAC rank on their unit.

    TWO RANKS, ONE MAPPING. A unit has its own ladder - the handoff allows many
    custom ranks and says each MUST name one of Arma's seven - and Arma has the
    seven it has. This reads the player's rankId, finds the rank's armaRank, and
    sets that. The unit's own name and insignia are what the roster shows; the
    Arma rank is what the engine's own AI and scoreboard read.

    LOCAL TO THE UNIT. setRank has local effect on the argument, so this runs
    where the player is - the server remoteExecs it to the owner, which is the
    pattern FUNC(applySkills) follows for the same reason and the reason
    ghostD_players_fnc_setRank already does it that way.

    A RANK THE STRUCTURE HAS LOST IS LEFT ALONE. An orphaned rankId is flagged
    by FUNC(storeLoad) for the admin panel; it is not this function's job to
    guess, and it is certainly not its job to demote somebody because a config
    file was renamed.

Parameters:
    0: The unit <OBJECT>
    1: rankId <STRING>

Returns:
    The Arma rank set, or "" <STRING>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]], ["_rankId", "", [""]]];

if (isNull _unit || {!local _unit}) exitWith {""};
if (_rankId isEqualTo "") exitWith {""};

private _rank = (GVAR(structure) getOrDefault ["ranks", createHashMap]) getOrDefault [_rankId, createHashMap];
if (count _rank isEqualTo 0) exitWith {
    WARNING_1("rank '%1' is not in the structure - unit left as it is",_rankId);
    ""
};

private _arma = toUpper (_rank getOrDefault ["armaRank", ""]);
if !(_arma in ARMA_RANKS) exitWith {
    WARNING_2("rank '%1' names armaRank '%2', which is not one of Arma's seven",_rankId,_arma);
    ""
};

_unit setRank _arma;

// The same variable ghostD_players_fnc_setRank writes, so anything that reads
// the player's rank off the unit sees the PAC answer and not a stale one.
_unit setVariable [QEGVAR(Player,rank), _arma];

_arma
