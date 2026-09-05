#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_logRecv

Description:
    The answer to FUNC(adminLog), arriving on the admin's machine: keeps the
    rows and redraws the management window's LOG section if it is open.

Parameters:
    0: Rows, newest first <ARRAY>
    1: How many rows the server holds in all <NUMBER>

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_rows", [], [[]]], ["_total", 0, [0]]];

if (!hasInterface) exitWith {};

GVAR(logRows) = _rows;
GVAR(logTotal) = _total;

[] call FUNC(manageSection);
[] call FUNC(panelLog);
