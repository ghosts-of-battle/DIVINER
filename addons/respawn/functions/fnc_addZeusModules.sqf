#include "script_component.hpp"
/*
 * Author: veteran29
 * Adds custom modules to Zeus via Zeus Enhanced framework.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (isNil "zen_custom_modules_fnc_register" || !isMultiplayer) exitWith {};

LOG("Adding ZEN modules");

private _iconRespawn = getText (configFile >> "CfgVehicles" >> QGVAR(moduleRespawn) >> "portrait");

[GHOST_CATEGORY, "Respawn sides", {
    [
        "Respawn sides",
        [
            [
                "SIDES",
                "Sides to respawn",
                [],
                false
            ]
        ],
        {
            params ["_dialogValues"];
            _dialogValues params ["_sides"];
            TRACE_1("",_dialogValues);

            private _players = allPlayers select {side group _x in _sides && !alive _x};

            ["Respawn", format ["Respawning %1 players", count _players], [1, 0.8, 0.3, 1]] call EFUNC(notify,notify);
            [QGVAR(force), nil, _players] call CBA_fnc_targetEvent;
        }
    ] call zen_dialog_fnc_create;
}, _iconRespawn] call zen_custom_modules_fnc_register;

[GHOST_CATEGORY, "Respawn player", {
    private _deadPlayers = allPlayers select {!alive _x};
    private _deadPlayersNames = _deadPlayers apply {format ["%1 (%2)", name _x, side group _x]};

    if (_deadPlayers isEqualTo []) exitWith {
        [objNull, "No dead players"] call BIS_fnc_showCuratorFeedbackMessage;
    };

    [
        "Respawn player",
        [
            [
                "LIST",
                "Dead players:",
                [
                    _deadPlayers,
                    _deadPlayersNames,
                    0,
                    10
                ],
                true
            ]
        ],
        {
            params ["_dialogValues", "_deadPlayers"];
            _dialogValues params ["_selected"];
            TRACE_1("",_dialogValues);

            ["Respawn", format ["Respawning %1", name _selected], [1, 0.8, 0.3, 1]] call EFUNC(notify,notify);

            [QGVAR(force), nil, _selected] call CBA_fnc_targetEvent;
        },
        {},
        _deadPlayers
    ] call zen_dialog_fnc_create;
}, _iconRespawn] call zen_custom_modules_fnc_register;
