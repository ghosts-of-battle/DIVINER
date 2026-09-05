#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_notify_fnc_tick

Description:
    Expires finished notifications, slides the survivors down to close the gap
    and pulls anything waiting out of the queue. Runs only while the stack is
    not empty, and removes itself when it is.

Parameters (CBA PFH): 0: args, 1: handle

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["", "_handle"];

private _display = uiNamespace getVariable [QGVAR(hud), displayNull];
if (isNull _display) exitWith {
    GVAR(slots) = [];
    GVAR(pfh) = -1;
    [_handle] call CBA_fnc_removePerFrameHandler;
};

private _now = CBA_missionTime;
private _live = [];
{
    _x params ["_slot", "_expire"];
    if (_now >= _expire) then {
        {
            private _c = _display displayCtrl _x;
            _c ctrlSetFade 1;
            _c ctrlCommit 0.25;
        } forEach [IDC_SLOT(_slot), IDC_BAR(_slot), IDC_TEXT(_slot)];
    } else {
        _live pushBack _x;
    };
} forEach GVAR(slots);

// restack: row order follows the order they were raised in
if (count _live != count GVAR(slots)) then {
    {
        _x params ["_slot"];
        {
            _x ctrlCommit SLIDE_TIME;
        } forEach ([_display, _slot, _forEachIndex] call FUNC(place));
    } forEach _live;
};
GVAR(slots) = _live;

// backfill from the queue
while {count GVAR(queue) > 0 && {count GVAR(slots) < (GVAR(maxVisible) min SLOT_COUNT)}} do {
    private _next = GVAR(queue) deleteAt 0;
    [_display, _next select 0, _next select 1, _next select 2] call FUNC(show);
};

if (GVAR(slots) isEqualTo [] && {GVAR(queue) isEqualTo []}) then {
    GVAR(pfh) = -1;
    [_handle] call CBA_fnc_removePerFrameHandler;
};
