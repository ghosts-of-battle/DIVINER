#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_leaderNotice

Description:
    The moment a player takes a leader slot, tells them their METT-TC is
    owed and opens the compose on it. Called from the groups addon at the
    end of its role setup, with whether this was a respawn.

    A LEADER SLOT IS ONE THAT SETS isLeader - the mission's own flag, the
    one the role's customVariables carry and every net tag reads. Not
    `leader group`: the group system hands leadership to whoever joined
    last, and a rifleman who is technically the leader of a two-man group
    for a moment is not a man who owes an estimate.

    ONCE, ON TAKING THE SLOT. A respawn is the same man in the same slot
    and gets nothing. The notice comes at once; the compose waits until the
    group menu has closed and the player is standing, and only opens if the
    tacpad is there to open it in.

Parameters:
    0: Was this a respawn <BOOL>

Returns:
    Whether the notice was given <BOOL>

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_isRespawn", false, [false]]];

if (!hasInterface || _isRespawn) exitWith {false};
if ((player getVariable ["isLeader", false]) isNotEqualTo true) exitWith {false};

private _opordId = GVAR(settings) getOrDefault ["currentOpord", ""];
private _against = "";
if (_opordId isNotEqualTo "") then {
    private _hdr = ((GVAR(structure) getOrDefault ["opords", createHashMap]) getOrDefault [_opordId, createHashMap]) getOrDefault ["header", createHashMap];
    _against = format [" against %1", _hdr getOrDefault ["title", _opordId]];
};

["TAC//PAC", format ["You hold a leader slot. File your METT-TC%1 - opening the compose.", _against], [0.780, 0.510, 0.129, 1]] call EFUNC(notify,notify);

if (isNil "ghostD_tacpad_fnc_composeOpen") exitWith {true};

[] spawn {
    sleep 2;
    // Not over the group menu, and not while dead or in the void between.
    waitUntil {sleep 0.5; !dialog && {alive player}};
    ["", "mettc", false, "", []] call ghostD_tacpad_fnc_composeOpen;
};

true
