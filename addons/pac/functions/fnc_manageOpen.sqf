#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_manageOpen

Description:
    Opens the management window - the action log, the ORBAT editor and
    the operator files - from the admin page. Admin-checked here for the
    flash; on load again, and on the server for every write.

Parameters:
    None

Returns:
    Whether it opened <BOOL>

Author:
    YonV
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {false};
if !([player] call ghostD_adminpanel_fnc_isAdmin) exitWith {false};

createDialog QGVAR(manage)
