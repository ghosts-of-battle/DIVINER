#include "script_component.hpp"
/*
    File: fnc_uiEsc.sqf
    Author: YonV
    Description: Make a string safe inside structured text - an ampersand or
        an angle bracket in a player's name would otherwise be read as
        markup and the whole block would vanish.

    Parameters:
        0: Text <STRING>

    Returns:
        The text with &, < and > escaped <STRING>
*/

params [["_s", "", [""]]];

if (_s isEqualTo "") exitWith {""};
_s = [_s, "&", "&amp;"] call CBA_fnc_replace;
_s = [_s, "<", "&lt;"] call CBA_fnc_replace;
[_s, ">", "&gt;"] call CBA_fnc_replace
