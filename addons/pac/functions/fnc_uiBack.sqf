#include "script_component.hpp"
/*
    File: fnc_uiBack.sqf
    Author: YonV
    Description: The BACK button - one step up the page history. With nothing
        to go back to it goes to the dashboard.

    Parameters:
        None

    Returns:
        Nothing
*/

if (count GVAR(uiHistory) > 1) then {
    GVAR(uiHistory) deleteAt ((count GVAR(uiHistory)) - 1);
    (GVAR(uiHistory) # ((count GVAR(uiHistory)) - 1)) params ["_page", "_args"];
    [_page, _args, false] call FUNC(uiGo);
} else {
    GVAR(uiHistory) = [];
    ["dashboard"] call FUNC(uiGo);
};
