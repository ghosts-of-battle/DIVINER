/*
    Author: TheTimidShade

    Description:
        Updates toggleable button controls for admin panel

    Parameters:
        0: OJECT - Currently selected player
        
    Returns:
        NONE
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

disableSerialization;

params ["_player"];




// A HELD TOGGLE IS AN ACCENT FILL. It was a hardcoded orange, which is the
// colour this panel used to be and not a colour ghost has - and being redrawn
// ten times a second it would have painted straight over the scheme every tick,
// whichever scheme the player chose. The two colours are read from the tacpad
// theme instead, so the plates follow Night Olive and Sand like everything else.
//
// The text on a filled plate goes to the GROUND colour, not to white: that is
// the suite's inverted state, and white on a light accent cannot be read.
([] call EFUNC(tacpad,theme)) params ["_themeGround", "_themeInk", "_themeAccent"];

#define COL_BUTTON_TEXT_ACTIVE _themeGround
#define COL_BUTTON_TEXT_INACTIVE _themeInk
#define COL_BUTTON_ACTIVE _themeAccent
#define COL_BUTTON_INACTIVE [0,0,0,0]

private _admp_display = uiNamespace getVariable ['admp_displayVar', displayNull];
if (isNull _admp_display) exitWith {}; // check display exists

// get all utility controls that need updating
private _godmode_ctrl = _admp_display displayCtrl IDC_ADMINPANEL_UTILITIES_GODMODE;
private _godmode_back = _admp_display displayCtrl IDC_ADMINPANEL_UTILITIES_GODMODE_BACK;
private _ammo_ctrl = _admp_display displayCtrl IDC_ADMINPANEL_UTILITIES_INFAMMO;
private _ammo_back = _admp_display displayCtrl IDC_ADMINPANEL_UTILITIES_INFAMMO_BACK;
private _ghost_ctrl = _admp_display displayCtrl IDC_ADMINPANEL_UTILITIES_GHOST;
private _ghost_back = _admp_display displayCtrl IDC_ADMINPANEL_UTILITIES_GHOST_BACK;

private _lock_ctrl = _admp_display displayCtrl IDC_ADMINPANEL_ADMIN_SERVERLOCK;
private _zeus_ctrl = _admp_display displayCtrl IDC_ADMINPANEL_ADMIN_ZEUS;
private _zeus_back = _admp_display displayCtrl IDC_ADMINPANEL_ADMIN_ZEUS_BACK;
private _spectate_ctrl = _admp_display displayCtrl IDC_ADMINPANEL_ADMIN_SPECTATE;
private _spectate_back = _admp_display displayCtrl IDC_ADMINPANEL_ADMIN_SPECTATE_BACK;

private _promote_ctrl = _admp_display displayCtrl IDC_ADMINPANEL_ADMIN_PROMOTE;
private _promote_back = _admp_display displayCtrl IDC_ADMINPANEL_ADMIN_PROMOTE_BACK;

// update status on controls
private _godmode = _player in admp_utilities_godmode_enabledUnits;
if (_godmode && !isNull _player) then { // if selected target not found set button to inactive
    _godmode_ctrl ctrlSetTextColor COL_BUTTON_TEXT_ACTIVE;
    _godmode_back ctrlSetBackgroundColor COL_BUTTON_ACTIVE;
} else {
    _godmode_ctrl ctrlSetTextColor COL_BUTTON_TEXT_INACTIVE;
    _godmode_back ctrlSetBackgroundColor COL_BUTTON_INACTIVE;
};

private _infammo = _player in admp_utilities_infammo_enabledUnits;
if (_infammo && !isNull _player) then {
    _ammo_ctrl ctrlSetTextColor COL_BUTTON_TEXT_ACTIVE;
    _ammo_back ctrlSetBackgroundColor COL_BUTTON_ACTIVE;
} else {
    _ammo_ctrl ctrlSetTextColor COL_BUTTON_TEXT_INACTIVE;
    _ammo_back ctrlSetBackgroundColor COL_BUTTON_INACTIVE;
};

private _ghost = _player in admp_utilities_ghost_enabledUnits;
if (_ghost && !isNull _player) then {
    _ghost_ctrl ctrlSetTextColor COL_BUTTON_TEXT_ACTIVE;
    _ghost_back ctrlSetBackgroundColor COL_BUTTON_ACTIVE;
} else {
    _ghost_ctrl ctrlSetTextColor COL_BUTTON_TEXT_INACTIVE;
    _ghost_back ctrlSetBackgroundColor COL_BUTTON_INACTIVE;
};

private _hasZeus = !isNull(getAssignedCuratorLogic _player);
if (_hasZeus && !isNull _player) then {
    _zeus_ctrl ctrlSetTextColor COL_BUTTON_TEXT_ACTIVE;
    _zeus_back ctrlSetBackgroundColor COL_BUTTON_ACTIVE;
} else {
    _zeus_ctrl ctrlSetTextColor COL_BUTTON_TEXT_INACTIVE;
    _zeus_back ctrlSetBackgroundColor COL_BUTTON_INACTIVE;
};

private _spectatorActive = !isNull (findDisplay 60492);
if (_spectatorActive) then {
    _spectate_ctrl ctrlSetTextColor COL_BUTTON_TEXT_ACTIVE;
    _spectate_back ctrlSetBackgroundColor COL_BUTTON_ACTIVE;
} else {
    _spectate_ctrl ctrlSetTextColor COL_BUTTON_TEXT_INACTIVE;
    _spectate_back ctrlSetBackgroundColor COL_BUTTON_INACTIVE;
};

if (admp_admin_serverLockState) then {
    _lock_ctrl ctrlSetText "UNLOCK SERVER";
} else {
    _lock_ctrl ctrlSetText "LOCK SERVER";
};

if ((getPlayerUID _player) in admp_authorisedIDs) then {
    _promote_ctrl ctrlSetTextColor COL_BUTTON_TEXT_ACTIVE;
    _promote_back ctrlSetBackgroundColor COL_BUTTON_ACTIVE;
    _promote_ctrl ctrlSetText "REVOKE ADMIN";
} else {
    _promote_ctrl ctrlSetTextColor COL_BUTTON_TEXT_INACTIVE;
    _promote_back ctrlSetBackgroundColor COL_BUTTON_INACTIVE;
    _promote_ctrl ctrlSetText "GRANT ADMIN";
};
