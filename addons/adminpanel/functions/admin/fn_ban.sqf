/*
    Author: JohnnyShootos (Edited by TheTimidShade)

    Description:
        Prompts the player for confirmation then bans the selected target

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

// make sure the player cannot ban themselves
if (_player == player) exitWith {["Admin Panel", "You cannot ban yourself!", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify); playSound "addItemFailed";};

if (call BIS_fnc_admin != 2) exitWith {["Admin Panel", "You must be the currently logged in admin to perform this action!", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify); playSound "addItemFailed";};

private _message = format ["Are you sure you want to ban %1?", name _player];
private _confirm = [_message, "CONFIRM BAN", "BAN", "CANCEL"] call BIS_fnc_guiMessage;

if (_confirm) then {
    private _command = format["#ban %1", name _player];
    serverCommand _command;
};
