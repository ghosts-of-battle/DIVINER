#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_textRecv

Description:
    The answer to FUNC(adminText), on the admin's machine: the text goes to
    the clipboard and to the .rpt, and a notification says so. The .rpt copy
    is the one that survives the admin forgetting to paste.

Parameters:
    0: Title <STRING>
    1: Text <STRING>

Returns:
    Nothing

Author:
    YonV
---------------------------------------------------------------------------- */

params [["_title", "", [""]], ["_text", "", [""]]];

if (!hasInterface) exitWith {};

copyToClipboard _text;
diag_log format ["[TAC//PAC] %1:%2%3", _title, endl, _text];

["TAC//PAC", format ["%1 copied to clipboard (%2 lines) and written to the .rpt.", _title, count (_text splitString endl)], [0.4, 0.702, 0.4, 1]] call EFUNC(notify,notify);
