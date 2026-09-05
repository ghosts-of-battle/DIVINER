#include "script_component.hpp"

[{
    if (!GVAR(loggingEnabled)) exitWith {};

    INFO("Friendly fire logging enabled");

    if (hasInterface) then {
        // On the CBA unit event, not a one-shot waitUntil: the Hit handler
        // rides the player OBJECT, and the object changes on respawn - bound
        // once, FF logging silently stopped after the first death.
        ["unit", {
            params ["_new", "_old"];
            if (!isNull _old && {!isNil QGVAR(ehId)}) then {
                _old removeEventHandler ["Hit", GVAR(ehId)];
            };
            if (isNull _new) exitWith {};
            INFO("Adding friendly fire EH");
            GVAR(ehId) = _new addEventHandler ["Hit", {
                params ["_target", "_shooter"];

                if (
                    !isPlayer _shooter
                    || {side group _target != side group _shooter
                    || _target isEqualTo _shooter}
                ) exitWith {};

                [QGVAR(friendlyFire), [_target, _shooter, vehicle _shooter]] call CBA_fnc_globalEvent;
            }];
        }, true] call CBA_fnc_addPlayerEventHandler;
    };

    [QGVAR(friendlyFire), {
        params ["_victim", "_origin", "_originVehicle"];
        private _nl = toString [13, 10] + "    ";

        private _msg = if (_originVehicle isKindOf "CAManBase") then {
            [
                _nl,
                name _origin, " shot at ", name _victim, _nl,
                "Victim-Origin distance: ", _victim distance _origin
            ] joinString ""
        } else {
            // The VEHICLE's name - configOf _origin named the man's class in
            // the line meant to name the offending vehicle.
            private _displayName = getText (configOf _originVehicle >> "displayName");
            [
                _nl,
                _displayName, " shot at ", name _victim, _nl,
                "Gunner:                 ", name gunner _originVehicle, _nl,
                "Commander:              ", name commander _originVehicle, _nl,
                "Driver:                 ", name driver _originVehicle, _nl,
                "Shooter:                ", name _origin, _nl,
                "Victim-Origin distance: ", _victim distance _originVehicle
            ] joinString ""
        };

        WARNING(_msg);
    }] call CBA_fnc_addEventHandler;
}] call EFUNC(common,runAfterSettingsInit);
