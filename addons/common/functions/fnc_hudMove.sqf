#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_hudMove

Description:
    Opens the reposition dialog for a HUD overlay. The player drags a stand-in
    box the same size as the real panel and saves; the HUD reads the result the
    next time it opens.

    This exists because a cutRsc title layer takes no mouse input, so the live
    HUD can never be dragged directly - the same reason DUI and ACE do it this
    way.

Parameters:
    _id      : STRING - HUD identifier, matching FUNC(hudPos).
    _size    : ARRAY  - [w, h] in safezone fractions, so the stand-in matches.
    _default : ARRAY  - [x, y] fractions that Reset restores.
    _label   : STRING - text drawn in the stand-in. Optional.

Returns:
    BOOL - true if the dialog opened.

Example:
    ["hackStrip", [0.34, 0.075], [0.33, 0.86], "HACK"] call ghostD_common_fnc_hudMove

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_id", "", [""]], ["_size", [0.2, 0.06], [[]]], ["_default", [0.4, 0.9], [[]]], ["_label", "", [""]]];

if (!hasInterface || _id isEqualTo "") exitWith { false };

if !(createDialog QGVAR(hudMove)) exitWith { false };

private _display = uiNamespace getVariable [QGVAR(hudMove), displayNull];
if (isNull _display) exitWith { false };

_size params ["_fw", "_fh"];
([_id, _default, _size] call FUNC(hudPos)) params ["_x", "_y"];

private _box = _display displayCtrl IDC_HUDMOVE_BOX;
_box ctrlSetPosition [_x, _y, _fw * safeZoneW, _fh * safeZoneH];
_box ctrlSetText _label;
_box ctrlCommit 0;

// Drag state lives on the display so the handlers stay closure-free.
_display setVariable [QGVAR(dragging), false];
_display setVariable [QGVAR(hudId), _id];
_display setVariable [QGVAR(hudDefault), _default];
_display setVariable [QGVAR(hudSize), _size];

_box ctrlAddEventHandler ["MouseButtonDown", {
    params ["_ctrl"];
    private _d = ctrlParent _ctrl;
    private _p = ctrlPosition _ctrl;
    _d setVariable [QGVAR(dragging), true];
    // Remember where in the box the player grabbed it, so it does not jump.
    _d setVariable [QGVAR(grab), [(_this select 2) - (_p select 0), (_this select 3) - (_p select 1)]];
}];

// THE DRAG RIDES MouseHolding, NOT MouseMoving. A control raises MouseMoving
// only while no button is down; with a button held - which is what a drag IS -
// the engine raises MouseHolding instead. Hung on MouseMoving alone, the box
// armed on the press and then never followed the cursor: the dialog said drag
// and nothing dragged. Both events carry the same arguments, so one handler
// serves both - and it is on the box as well as the catcher, because the
// cursor spends the whole drag over the box it is towing.
private _fnc_track = {
    params ["_ctrl", "_mx", "_my"];
    private _d = ctrlParent _ctrl;
    if !(_d getVariable [QGVAR(dragging), false]) exitWith {};
    (_d getVariable [QGVAR(grab), [0, 0]]) params ["_gx", "_gy"];
    private _b = _d displayCtrl IDC_HUDMOVE_BOX;
    private _p = ctrlPosition _b;
    _b ctrlSetPosition [_mx - _gx, _my - _gy, _p select 2, _p select 3];
    _b ctrlCommit 0;
};
private _fnc_drop = {
    (ctrlParent (_this select 0)) setVariable [QGVAR(dragging), false];
};

private _catch = _display displayCtrl IDC_HUDMOVE_CATCH;
{
    _x ctrlAddEventHandler ["MouseMoving", _fnc_track];
    _x ctrlAddEventHandler ["MouseHolding", _fnc_track];
    _x ctrlAddEventHandler ["MouseButtonUp", _fnc_drop];
} forEach [_catch, _box];

(_display displayCtrl IDC_HUDMOVE_SAVE) ctrlAddEventHandler ["ButtonClick", {
    private _d = ctrlParent (_this select 0);
    private _p = ctrlPosition (_d displayCtrl IDC_HUDMOVE_BOX);
    private _id = _d getVariable [QGVAR(hudId), ""];
    [
        _id,
        [((_p select 0) - safeZoneX) / safeZoneW, ((_p select 1) - safeZoneY) / safeZoneH]
    ] call FUNC(hudSetPos);
    _d closeDisplay 1;
    [QGVAR(hudMoved), [_id]] call CBA_fnc_localEvent;
}];

(_display displayCtrl IDC_HUDMOVE_RESET) ctrlAddEventHandler ["ButtonClick", {
    private _d = ctrlParent (_this select 0);
    private _id = _d getVariable [QGVAR(hudId), ""];
    [_id, []] call FUNC(hudSetPos);
    _d closeDisplay 1;
    [QGVAR(hudMoved), [_id]] call CBA_fnc_localEvent;
}];

(_display displayCtrl IDC_HUDMOVE_CANCEL) ctrlAddEventHandler ["ButtonClick", {
    (ctrlParent (_this select 0)) closeDisplay 2;
}];

true
