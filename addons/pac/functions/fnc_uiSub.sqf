#include "script_component.hpp"
/*
    File: fnc_uiSub.sqf
    Author: YonV
    Description: Switch a page's sub-tab. The same page with different
        arguments, and it REPLACES the top of the history rather than adding
        to it - so BACK from a role's "Nets" tab goes to the roles list, not
        back through Identity first, the way the website's back button does
        not walk through every tab you looked at.

    Parameters:
        0: Page <STRING>
        1: Arguments <HASHMAP>

    Returns:
        Nothing
*/

params [["_page", "", [""]], ["_args", createHashMap, [createHashMap]]];

private _n = count GVAR(uiHistory);
if (_n > 0) then {
    GVAR(uiHistory) set [_n - 1, [_page, _args]];
} else {
    GVAR(uiHistory) pushBack [_page, _args];
};
[_page, _args, false] call FUNC(uiGo);
