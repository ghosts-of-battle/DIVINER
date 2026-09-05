/*
    Author: Dom -- Tinkered with by YonV
    Description:
        Toggles a role-access grant (Role_Access whitelist bypass) on the selected player.
        LMB = this mission only, SHIFT+LMB = stored persistently on the server.

    Parameters:
        0: Persistent <BOOL>

    Returns:
        NONE
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

disableSerialization;


params [["_persistent",false,[false]]];

private _admp_display = uiNamespace getVariable ['admp_displayVar', displayNull];
if (isNull _admp_display) exitWith {}; // check display exists

private _admp_playerlist_listbox = _admp_display displayCtrl IDC_ADMINPANEL_PLAYERLIST_LISTBOX;
private _player = [_admp_playerlist_listbox] call admp_fnc_playerFromSelection; // get selected player

if (isNull _player) exitWith {["Admin Panel", "No target found!", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify); playSound "addItemFailed";}; // if there is no selected target exit

// ROLE GATING IS THE MISSION'S. Who may take a medic slot is a mission rule, so
// there is nothing here to toggle when no mission defines one - and saying so is
// better than a silent no-op that looks like a broken button.
if (isNil "ghostD_groups_fnc_toggleRoleGrant") exitWith {
    ["Admin Panel", "This mission has no role gating to grant.", [1, 0.776, 0.102, 1]] call EFUNC(notify,notify);
};

[_player,_persistent,player] remoteExecCall ["ghostD_groups_fnc_toggleRoleGrant",2];
playSound "3DEN_notificationDefault";
