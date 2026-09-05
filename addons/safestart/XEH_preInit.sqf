#include "script_component.hpp"
ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

[QGVAR(enableSafety), {
    params ["_player"];

    [_player] call FUNC(lowerWeapon);

    // Nested, not one bare && - GVAR(startLocked) is only REGISTERED when
    // ace_safemode is loaded, and a non-lazy && evaluates both sides:
    // without the mod the old line threw on every enableSafety.
    if (EGVAR(common,aceSafemode)) then {
        if (GVAR(startLocked)) then {
            [_player, currentWeapon _player, true] call ACEFUNC(safemode,setWeaponSafety);
        };
    };
}] call CBA_fnc_addEventHandler;

[QGVAR(lowerWeapon), {
    params ["_unit"];

    _unit action ["WeaponOnBack", _unit];

}] call CBA_fnc_addEventHandler;

ADDON = true;
