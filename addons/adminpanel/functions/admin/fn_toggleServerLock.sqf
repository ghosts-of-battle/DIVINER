/*
    Author: JohnnyShootos (Edited by TheTimidShade)

    Description:
        Sets server lock state

    Parameters:
        NONE
        
    Returns:
        NONE
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

disableSerialization;


private _admp_display = uiNamespace getVariable ['admp_displayVar', displayNull];
if (isNull _admp_display) exitWith {}; // check display exists

private _lock_ctrl = _admp_display displayCtrl IDC_ADMINPANEL_ADMIN_SERVERLOCK;

if (call BIS_fnc_admin != 2) exitWith {["Admin Panel", "You must be the currently logged in admin to perform this action!", [0.831, 0.267, 0.267, 1]] call EFUNC(notify,notify); playSound "addItemFailed";};

if (!admp_admin_serverLockState) then {
    serverCommand "#lock";
    ["Admin Panel", "Server locked!", [0.4, 0.702, 0.4, 1]] call EFUNC(notify,notify);
    playSound "3DEN_notificationDefault";
    _lock_ctrl ctrlSetText "UNLOCK SERVER";
    admp_admin_serverLockState = true; publicVariable "admp_admin_serverLockState";
} else {
    serverCommand "#unlock";
    ["Admin Panel", "Server unlocked!", [0.4, 0.702, 0.4, 1]] call EFUNC(notify,notify);
    playSound "3DEN_notificationDefault";
    _lock_ctrl ctrlSetText "LOCK SERVER";
    admp_admin_serverLockState = false; publicVariable "admp_admin_serverLockState";
};
