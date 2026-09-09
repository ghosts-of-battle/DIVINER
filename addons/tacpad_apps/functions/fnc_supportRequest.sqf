#include "script_component.hpp"
/*
 * Author: YonV
 * The request window: pick a point on the map and send the mission.
 *
 * CAS ONLY, SINCE 2026-09-05. Artillery used to open this window too - it asks
 * for rounds per gun, and the code for that is still here and still works if
 * something calls it with ARTILLERY - but the board now hands a fire mission
 * straight to Simplex's own request screen (user: "arty support call needs to
 * open the simplex panel"), so the only service that reaches this window from
 * TAC//SUPPORT is CAS. CAS asks for nothing beyond the point, because a strafe
 * run and a loiter station are both "there, please" and Simplex's own screen is
 * where the sheaf and the stack live. The window is one file per job - this
 * opens it, FUNC(supportRequestDraw) draws whichever service it is,
 * FUNC(supportRequestSend) sends it.
 *
 * OUR WINDOW, SIMPLEX'S GUNS. Every number on this screen is asked of Simplex
 * and every round is fired by it - EFUNC is not available across mods, so the
 * calls are by name: sss_artillery_fnc_canFire for whether a gun can reach the
 * point and how long the shell is in the air, sss_artillery_fnc_fire to send
 * it. Nothing here simulates anything, and nothing here decides who may fire.
 *
 * WHY NOT JUST OPEN THEIRS. Because their planner is twenty-nine screens' worth
 * of sheaf, dispersion, coordination and multi-task plans, in a different mod's
 * visual language, and the thing a man does ninety-five times in a hundred is
 * "guns, that grid, four rounds". That is this window. ADVANCED opens Simplex's
 * own planner for the other five, which is the honest split: we are not going
 * to clone a planner and we are not going to pretend the simple case needs one.
 *
 * EVERY GUN IN THE BATTERY FIRES. An entity is a battery, not a tube - it holds
 * sss_vehicles - so the rounds figure is rounds PER GUN and the window says so.
 * A four-gun battery asked for four rounds puts sixteen on the ground, which is
 * what a fire mission means and not what a naive reading of the number would
 * suggest.
 *
 * OUT OF RANGE IS ANSWERED BEFORE THE PRESS, not after it. canFire is asked
 * every time the target moves, so SEND is dead and says why rather than
 * accepting a mission that quietly does nothing.
 *
 * Arguments:
 * 0: The Simplex entity <OBJECT>
 * 1: Service name <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_entity", objNull, [objNull]], ["_service", "", [""]]];

if (isNull _entity) exitWith {};

if (isNil "sss_common_fnc_getEntities") exitWith {
    ["SUPPORT", "Simplex Support Services is not loaded.", "high"] call EFUNC(messaging,notify);
};

if !(createDialog QGVAR(supportDlg)) exitWith {};

private _display = uiNamespace getVariable [QGVAR(supportDlg), displayNull];
if (isNull _display) exitWith {};

_display setVariable [QGVAR(entity), _entity];
_display setVariable [QGVAR(service), _service];
_display setVariable [QGVAR(rounds), 4];
_display setVariable [QGVAR(target), []];

private _map = _display displayCtrl 8961;

// The map opens where the man is, because a fire mission is nearly always
// within a few kilometres of him and starting at the map's centre means panning
// every single time.
_map ctrlMapAnimAdd [0, 0.15, getPosATL (call CBA_fnc_currentUnit)];
ctrlMapAnimCommit _map;

_map ctrlAddEventHandler ["MouseButtonDown", {
    params ["_ctrl", "_button", "_x", "_y"];
    if (_button != 0) exitWith {};

    private _dlg = ctrlParent _ctrl;
    _dlg setVariable [QGVAR(target), _ctrl posScreenToWorld [_x, _y]];
    [_dlg] call FUNC(supportRequestDraw);
}];

// The target ring, drawn on the map itself rather than as a control - a control
// cannot follow a map that pans.
_map ctrlAddEventHandler ["Draw", {
    params ["_ctrl"];
    private _at = (ctrlParent _ctrl) getVariable [QGVAR(target), []];
    if (_at isEqualTo []) exitWith {};

    ([] call EFUNC(tacpad,theme)) params ["", "", "_accent"];

    // Plain commas, not ARR_. This is a code block in a file, not an argument
    // to a macro - and CBA stops at ARR_8 anyway, which drawIcon's eleven
    // arguments are past.
    _ctrl drawEllipse [_at, 120, 120, 0, _accent, ""];
    _ctrl drawIcon [
        "\a3\ui_f\data\map\markers\military\dot_ca.paa",
        _accent, _at, 18, 18, 0, "", 0, 0.05, "RobotoCondensed", "right"
    ];
}];

[_display] call FUNC(supportRequestDraw);

nil
