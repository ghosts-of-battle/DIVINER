#include "script_component.hpp"
/*
 * Author: Ghost
 * Builds `admp_authorisedIDs` - who this mission lets into the panel.
 *
 * THE LIST STAYS IN THE MISSION, and that is the whole point of this function.
 * The panel used to `#include` the mission's admin list at compile time, which
 * an addon cannot do: an addon is compiled once, for every mission.
 *
 * ONE WAY FOR A MISSION TO SAY IT.
 *
 *   CfgGhostAdmins in description.ext - the one to use. It sits beside the
 *   mission's OTHER admin arrays (enableDebugConsole, cba_settings_whitelist)
 *   so one edit covers the debug console, the CBA whitelist and this panel:
 *
 *       #define ADMINS "765...", "765..."
 *       enableDebugConsole[] = {ADMINS};
 *       cba_settings_whitelist[] = {ADMINS};
 *       class CfgGhostAdmins { admins[] = {ADMINS}; };
 *
 * Plus the mod's own admins, so a mission that names nobody is not locked out.
 * Nothing here writes back to the mission.
 *
 * THE LEGACY config\config_adminlist.hpp PATH IS GONE (2026-09-03). It read
 * an optional missionConfig_admins variable a mission could leave behind,
 * defaulted to [], and no mission on this framework has ever set it - so it
 * read as a dangling lookup of something nothing writes, which is exactly what
 * it was mistaken for. CfgGhostAdmins is the way in.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * The uids <ARRAY>
 *
 * Example:
 * [] call ghostD_adminpanel_fnc_adminList
 *
 * Public: Yes
 */

private _ids = [];

// 1. THE MISSION'S CONFIG - the recommended place, and the one that shares its
//    array with enableDebugConsole and cba_settings_whitelist.
{
    if (_x isEqualType "" && _x isNotEqualTo "") then {_ids pushBackUnique _x};
} forEach (getArray (missionConfigFile >> "CfgGhostAdmins" >> "admins"));

// 2. The mod's own list - the uids ghost_admin already trusts with the debug
//    console. A mission with no admin list at all still has whoever the mod is
//    set up for, which is what stops a fresh mission locking everybody out of
//    the panel that would fix it.
{
    if (_x isEqualType "" && _x isNotEqualTo "") then {_ids pushBackUnique _x};
} forEach (getArray (configFile >> "enableDebugConsole"));

_ids
