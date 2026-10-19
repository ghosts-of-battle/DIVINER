#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_logRecv

Description:
    The answer to FUNC(adminLog), arriving on the admin's machine: keeps the
    rows and redraws the dashboard if it is open.

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

// The dashboard asks for the log and redraws when it lands (FUNC(uiRefresh)
// redraws only a page that reads, so a form is never wiped by this).
["log"] call FUNC(uiRefresh);
