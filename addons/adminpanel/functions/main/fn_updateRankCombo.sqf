/*
    Author: YonV

    Description:
        Populates the RANK combo (once) and selects the currently-selected player's rank.
        Sets admp_rank_suppressApply while doing so, so the programmatic selection does
        not trigger admp_fnc_setPlayerRank (which is bound to onLBSelChanged). Called on
        panel open and whenever the player-list selection changes.

    Parameters:
        NONE

    Returns:
        NONE
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

disableSerialization;


private _admp_display = uiNamespace getVariable ['admp_displayVar', displayNull];
if (isNull _admp_display) exitWith {}; // check display exists

private _admp_playerlist_listbox = _admp_display displayCtrl IDC_ADMINPANEL_PLAYERLIST_LISTBOX;
private _rank_combo = _admp_display displayCtrl IDC_ADMINPANEL_ADMIN_RANK_COMBO;

admp_rank_suppressApply = true;

private _ranks = ["Private","Corporal","Sergeant","Lieutenant","Captain","Major","Colonel"];

// populate once
if (lbSize _rank_combo != count _ranks) then {
    lbClear _rank_combo;
    {
        private _i = _rank_combo lbAdd _x;
        _rank_combo lbSetData [_i, _x];
    } forEach _ranks;
};

private _player = [_admp_playerlist_listbox] call admp_fnc_playerFromSelection; // get selected player

if (isNull _player) then {
    _rank_combo lbSetCurSel -1;
} else {
    // Proper-case name, e.g. "Sergeant". The mission's rank map when there is
    // one - see fn_updatePlayerList for why it cannot be assumed - and the
    // engine's own rank when there is not.
    private _rank = if (isNil "ghostD_players_fnc_getRank") then {
        rank _player
    } else {
        [_player] call ghostD_players_fnc_getRank
    };
    private _idx = _ranks findIf {toUpper _x isEqualTo toUpper _rank};
    if (_idx < 0) then {_idx = 0};
    _rank_combo lbSetCurSel _idx;
};

admp_rank_suppressApply = false;
