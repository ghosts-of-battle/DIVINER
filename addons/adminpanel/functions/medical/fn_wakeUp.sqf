/*
    Author: TheTimidShade

    Description:
        Wakes up the selected unit if they have stable enough vitals

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
private _player = [_admp_playerlist_listbox] call admp_fnc_playerFromSelection; // get selected player

if (isNull _player) exitWith {["Admin Panel", "No target found!", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify); playSound "addItemFailed";}; // if there is no selected target exit


if (!(_player getVariable ["ACE_isUnconscious", false])) exitWith {["Admin Panel", format ["%1 is already conscious!", name _player], [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify); playSound "addItemFailed";};

[_player, false] remoteExec ["ACM_zeus_fnc_forceWakeUp", _player, false];

sleep 0.1; // small sleep to let state update

if (_player getVariable ["ACE_isUnconscious", false]) then {
    ["Admin Panel", format ["Failed to wake %1!", name _player], [0.4, 0.702, 0.4, 1]] call EFUNC(notify,notify);
    playSound "addItemFailed";
} else {
    ["Admin Panel", format ["Successfully woke %1!", name _player], [0.4, 0.702, 0.4, 1]] call EFUNC(notify,notify);
    playSound "3DEN_notificationDefault";
};
