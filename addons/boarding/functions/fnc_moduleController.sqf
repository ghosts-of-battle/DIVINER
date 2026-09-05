#include "script_component.hpp"
/*
 * Author: Ghost
 * Wires one boarding point: the objects synchronised to this module get an
 * ACE action that loads everybody standing near the module.
 *
 * The SWITCH and the MUSTER POINT are deliberately different things. The
 * object is where the action lives - somewhere a player can walk up to and
 * look at - while the range is measured from the MODULE, so a mission can put
 * the button by a door and still pick up the whole compound behind it.
 *
 * Vehicles synchronised to the module are the transport. With none, whatever
 * has free cargo near the module is used instead, so the simple case is one
 * module, one sign, and the trucks already parked there.
 *
 * isGlobal 1: the action has to exist on every client, so this runs on all of
 * them rather than only the server.
 *
 * Parameters (module standard): logic, units, activated
 *
 * Public: No
 */

params [
    ["_logic", objNull, [objNull]],
    ["_units", [], [[]]],
    ["_activated", true, [true]]
];

if (!_activated || {isNull _logic}) exitWith {};

private _range = (_logic getVariable ["range", BOARD_RANGE_DEF]) max 1;
private _title = _logic getVariable ["title", "Board Transport"];
if (_title isEqualTo "") then { _title = "Board Transport" };

private _synced = (synchronizedObjects _logic) select {!(_x isKindOf "Logic")};

// Vehicles are transport; everything else is a switch. A mission that syncs
// only a truck gets the action ON the truck, which is the obvious reading of
// "sync the thing they press".
private _vehicles = _synced select {_x isKindOf "AllVehicles"};
private _buttons = _synced select {!(_x isKindOf "AllVehicles")};
if (_buttons isEqualTo []) then { _buttons = _vehicles };

if (_buttons isEqualTo []) exitWith {
    WARNING("a Boarding Point module has nothing synchronised to it - there is nothing for players to press");
};

_logic setVariable [QGVAR(vehicles), _vehicles, true];
_logic setVariable [QGVAR(range), _range, true];

// Only the clients need the action; the server has nobody to press it.
if (!hasInterface) exitWith {};

{
    private _obj = _x;
    private _action = [
        QGVAR(board),
        _title,
        "\a3\ui_f\data\igui\cfg\actions\getincargo_ca.paa",
        {
            params ["_target", "_player", "_args"];
            _args params ["_logic"];
            [QGVAR(board), [_logic, _player]] call CBA_fnc_serverEvent;
        },
        {
            params ["_target", "_player", "_args"];
            _args params ["_logic"];
            [_logic, _player] call FUNC(canBoard)
        },
        {},
        [_logic]
    ] call ace_interact_menu_fnc_createAction;

    [_obj, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
} forEach _buttons;

INFO_3("boarding point up: %1 button(s), %2 vehicle(s), %3 m",count _buttons,count _vehicles,_range);
