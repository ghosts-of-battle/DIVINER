#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_sqfText

Description:
    An array written the way a CONFIG FILE writes it - braces, double quotes,
    commas, no spaces.

    WHY NOT str. `str` writes SQF: square brackets and, for a string, quotes
    that are not the ones a .hpp uses. What CAPTURE puts in the loadout box has
    to be the same text somebody could paste into config_roles.hpp and the same
    text the website's loadout box shows, or the three of them disagree about
    what a loadout looks like and one of them is silently wrong.

    Numbers, strings, booleans and nested arrays are all a loadout holds, so
    that is all this writes. A quote inside a string is doubled, which is how a
    config escapes one.

Parameters:
    0: The value <ANY>

Returns:
    The text <STRING>

Example:
    [getUnitLoadout player] call ghostD_pac_fnc_sqfText

Author:
    YonV
---------------------------------------------------------------------------- */

params ["_v"];

if (_v isEqualType []) exitWith {
    "{" + ((_v apply {[_x] call FUNC(sqfText)}) joinString ",") + "}"
};
if (_v isEqualType true) exitWith {["false", "true"] select _v};
if (_v isEqualType 0) exitWith {
    // A whole number reads as one: 30, not 30.0000 - which is what str gives
    // for a float that happens to be whole, and a config file never writes.
    if (_v isEqualTo floor _v && {abs _v < 1e9}) then {str (floor _v)} else {str _v}
};
if (_v isEqualType "") exitWith {
    """" + ([_v, """", """"""] call CBA_fnc_replace) + """"
};

// Anything else - objNull, a side, a hashmap - has no config spelling. Empty
// rather than something that will not parse.
""
