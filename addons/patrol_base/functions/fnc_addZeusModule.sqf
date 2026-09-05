#include "script_component.hpp"
/*
 * Author: Ghost
 * Registers a Zeus (ZEN) custom module that drops a set of Patrol Base Kit items
 * at the placement position, so a player can build a base there.
 * No-op if Zeus Enhanced isn't loaded.
 *
 * Arguments: None
 * Return Value: None
 *
 * Public: No
 */

if (isNil "zen_custom_modules_fnc_register") exitWith {};

private _icon = "\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\meet_ca.paa";

[
    "Ghosts of Battle",
    "Drop Patrol Base Kits",
    {
        // ZEN passes [position, object-under-cursor] - verified against
        // zen_custom_modules\fnc_init.sqf: `[_position, _attached] call _function`.
        private _pos = _this param [0, [], [[]]];
        if (_pos isEqualTo [] || {count _pos < 2}) then {
            _pos = call zen_common_fnc_getMousePosition;
        };
        if (_pos isEqualTo [] || {count _pos < 2}) exitWith {
            ["Patrol Base", "Could not read a drop position.", [1, 0.3, 0.3, 1]] call EFUNC(notify,notify);
        };

        private _n = missionNamespace getVariable [QGVAR(kitCount), 4];

        // A CBA SERVER EVENT, not a raw remoteExec of our own function.
        // remoteExec of a named function is subject to the MISSION's
        // CfgRemoteExec policy, and a mission that whitelists (rather than
        // allows everything) drops the call on the floor with no error and no
        // kits - which is exactly what "did not drop kits" looks like. CBA's
        // event channel is always reachable, and it is what the rest of this
        // mod already uses.
        [QGVAR(dropKits), [_pos, _n, player]] call CBA_fnc_serverEvent;
        diag_log text format ["[ghost_patrol_base] zeus drop requested: %1 kit(s) at %2", _n, mapGridPosition _pos];
    },
    _icon
] call zen_custom_modules_fnc_register;
