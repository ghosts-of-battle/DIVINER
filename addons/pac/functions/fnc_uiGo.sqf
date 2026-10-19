#include "script_component.hpp"
/*
    File: fnc_uiGo.sqf
    Author: YonV
    Description: Go to a page - the website's "?page=x&...".

        A PAGE IS A FUNCTION, FUNC(pg<Name>), and its arguments are a
        hashmap; the pair is pushed on a history so BACK can retrace it, the
        way the browser's back button does. A nav-bar click starts a fresh
        trail (FUNC(uiNav) clears the history first).

    Parameters:
        0: Page <STRING> - "dashboard", "roster", "player", ...
        1: Arguments <HASHMAP> (optional)
        2: Push on the history <BOOL> (optional, default true)

    Returns:
        Nothing
*/

params [["_page", "dashboard", [""]], ["_args", createHashMap, [createHashMap]], ["_push", true, [true]]];

if (_push) then {
    private _last = GVAR(uiHistory) param [(count GVAR(uiHistory)) - 1, []];
    // The same page with the same arguments is a redraw, not a step.
    if (_last isNotEqualTo [_page, _args]) then {GVAR(uiHistory) pushBack [_page, _args]};
};
GVAR(uiPage) = _page;
GVAR(uiArgs) = _args;
GVAR(uiFilterText) = "";

[] call FUNC(uiDraw);
