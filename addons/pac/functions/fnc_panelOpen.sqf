#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_panelOpen

Description:
    Opens the TAC//PAC admin page. Called from the admin console's button.
    The page checks the admin list again on load, so this check is only to
    save a non-admin the flash of a screen that closes itself.

Parameters:
    None

Returns:
    Whether the page opened <BOOL>

Author:
    YonV
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {false};
if !([player] call ghostD_adminpanel_fnc_isAdmin) exitWith {false};

createDialog QGVAR(panel)
