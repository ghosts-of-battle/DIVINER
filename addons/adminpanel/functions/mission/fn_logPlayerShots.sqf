/*
    Author: TheTimidShade

    Description:
        Logs player's fire events to the server log

    Parameters:
        NONE
        
    Returns:
        NONE
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

if (!hasInterface) exitWith {};

["ace_firedPlayer", {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile"];

    private _weaponName = getText (configFile >> "CfgWeapons" >> _weapon >> "DisplayName");
    private _message = format ["[GOB ADMIN] Player %1 fired weapon '%2'", name player, _weaponName];
    // THE LOCAL RPT AND THE SERVER'S. ghostD_diag_fnc_info's fourth argument
    // raises the line to the server as well, which ghost_init already listens
    // for - so there is no separate logToServer to guard against. The name this
    // guarded on, YMF_fnc_logToServer, stopped existing when the prefix became
    // ghost, so the isNil branch it chose was always the local-only one.
    [_message, "AdminShots", false, true] call ghostD_diag_fnc_info;

}] call CBA_fnc_addEventHandler;
