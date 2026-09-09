/*
    Author: YonV

    Description:
        Applies the RANK combo selection to the selected player. Sends the change to the
        server (ghostD_players_fnc_setRankOverride) which updates the live rank map - this
        drives role access via fn_canTakeRole - and dumps the promoted Steam IDs to the
        RPT. Bound to the rank combo's onLBSelChanged; ignores programmatic reselection
        via the admp_rank_suppressApply guard.

    Parameters:
        NONE

    Returns:
        NONE
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

disableSerialization;


// ignore selection changes fired while the combo is being populated/reselected
if (missionNamespace getVariable ["admp_rank_suppressApply", false]) exitWith {};

private _admp_display = uiNamespace getVariable ['admp_displayVar', displayNull];
if (isNull _admp_display) exitWith {}; // check display exists

private _admp_playerlist_listbox = _admp_display displayCtrl IDC_ADMINPANEL_PLAYERLIST_LISTBOX;
private _rank_combo = _admp_display displayCtrl IDC_ADMINPANEL_ADMIN_RANK_COMBO;

private _player = [_admp_playerlist_listbox] call admp_fnc_playerFromSelection; // get selected player
if (isNull _player) exitWith {["Admin Panel", "No target found!", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify); playSound "addItemFailed";};

private _sel = lbCurSel _rank_combo;
if (_sel < 0) exitWith {};
private _rank = _rank_combo lbData _sel;
if (_rank isEqualTo "") exitWith {};

// TAC//PAC IS THE SOURCE OF TRUTH FOR RANK when it is loaded: the change goes
// onto the man's PAC record through the same door the PAC page uses
// (ghostD_pac_fnc_adminSet, admin-checked on the server), PAC publishes, and
// getRank - which prefers PAC - reads it back everywhere. Writing the legacy
// map instead would be overridden the moment PAC re-applied (user, 2026-09-05).
// The record reaches the database when an admin presses SAVE on the PAC page.
private _viaPac = false;
if (!isNil "ghostD_pac_fnc_adminSet") then {
    private _ranks = (missionNamespace getVariable ["ghostD_pac_structure", createHashMap]) getOrDefault ["ranks", createHashMap];
    private _ids = keys _ranks;
    _ids sort true;
    private _hit = _ids findIf {toUpper ((_ranks get _x) getOrDefault ["armaRank", ""]) isEqualTo toUpper _rank};
    if (_hit >= 0) then {
        [player, getPlayerUID _player, "rankId", _ids # _hit] remoteExecCall ["ghostD_pac_fnc_adminSet", 2];
        _viaPac = true;
    };
};

if (_viaPac) exitWith {
    ["Admin Panel", format ["Set %1's rank to %2 in TAC//PAC - press SAVE on the PAC page to keep it.", name _player, _rank], [0.4, 0.702, 0.4, 1]] call EFUNC(notify,notify);
    playSound "3DEN_notificationDefault";
    // the server publishes the roster a moment later; redraw the list after it
    [{[] call admp_fnc_updatePlayerList}, [], 1] call CBA_fnc_waitAndExecute;
};

// THE RANK MAP IS THE MISSION'S. With the Roomba framework loaded the change
// goes to the server's override map, which is what drives role access; without
// it there is nothing persistent to write to and the engine's own rank is set
// instead, so the combo still does what it says on any mission.
if (isNil "ghostD_players_fnc_setRankOverride") then {
    [_player, _rank] remoteExecCall ["setRank", _player];
} else {
    [getPlayerUID _player, _rank, _player, name player] remoteExecCall ["ghostD_players_fnc_setRankOverride", 2];
};

["Admin Panel", format ["Set %1's rank to %2.", name _player, _rank], [0.4, 0.702, 0.4, 1]] call EFUNC(notify,notify);
playSound "3DEN_notificationDefault";

[] call admp_fnc_updatePlayerList; // refresh so the new rank shows next to the name
