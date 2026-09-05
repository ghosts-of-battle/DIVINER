#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_notify_fnc_broadcast

Description:
    Sends a notification to every client, or to one side only. The side filter
    is applied on the receiving client (see XEH_postInit), so intel meant for
    one side never reaches the others as a readable event payload beyond the
    text itself.

Parameters:
    _title  : STRING
    _text   : STRING - optional, default "".
    _colour : ARRAY  - RGBA, optional, default ember.
    _side   : SIDE   - optional; sideUnknown (default) means everyone.

Example:
    ["Intel", "Signal intercept plotted.", [0.91, 0.65, 0.24, 1], west] call ghostD_notify_fnc_broadcast

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_title", "", [""]], ["_text", "", [""]], ["_colour", [0.871, 0.361, 0.188, 1], [[]], 4], ["_side", sideUnknown, [sideUnknown]], ["_pos", [], [[]]]];

[QGVAR(post), [_title, _text, _colour, _side, _pos]] call CBA_fnc_globalEvent;
