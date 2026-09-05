#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A -- Tinkered with by YonV
 * THE COSMETIC CATALOGUE. One list, two readers: the ACE self-interaction menu
 * (FUNC(addCosmeticSelection)) and the MOTORPOOL spawner screen
 * (FUNC(motorpool_select)) both consume this, so a paint scheme added once
 * appears in both.
 *
 * THE CATALOGUE IS CONFIG NOW, AND IT LIVES IN THE MISSION. This used to be a
 * hand-built array in scripts\vehicle\fn_vehicle_cosmeticEntries.sqf - eighty
 * entries of SQF, three of the families built by forEach loops. It is
 * missionConfigFile >> "GHOSTFR_Cosmetics" instead, so adding a scheme is an edit
 * to config\config_cosmetics.hpp and nothing else: no mod rebuild, no code.
 *
 * THE RETURN SHAPE IS UNCHANGED - ["baseClass", "Display Name", ["icon", code]]
 * - so neither reader had to be touched. The code blocks read `_vehicle` as a
 * free variable from the caller's scope, exactly as they did before; bind
 * `private _vehicle = ...` before calling one.
 *
 * A label starting with "Toggle" is a fitting; anything else is a paint scheme.
 *
 * COMPILED ONCE AND CACHED. Both readers run per vehicle - the ACE menu on
 * every vehicle that gets actions, the motorpool on every selection change -
 * and compiling eighty code strings each time is work nobody asked for. The
 * cache is dropped if the mission config has nothing, so a mission that loads
 * a catalogue late still picks it up.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Entries <ARRAY>
 *
 * Example:
 * private _entries = call ghostD_vehicle_fnc_cosmeticEntries;
 *
 * Public: No
 */

private _cached = missionNamespace getVariable [QGVAR(cosmeticCache), []];
if (_cached isNotEqualTo []) exitWith {_cached};

private _root = missionConfigFile >> "GHOSTFR_Cosmetics";

if !(isClass _root) exitWith {
    // Not an error. A mission that defines no catalogue simply offers no paint
    // schemes, and both readers handle an empty list.
    INFO("VehicleCosmetics","No GHOSTFR_Cosmetics class in the mission config - no cosmetic entries.");
    []
};

private _out = [];

{
    private _entry = _x;
    private _vehicleClass = getText (_entry >> "vehicle");
    private _name = getText (_entry >> "name");
    private _code = getText (_entry >> "code");

    // A NAMELESS OR CLASSLESS ENTRY IS A TYPO, AND IT SAYS SO. Skipping it
    // quietly would mean a paint that never appears and no reason why.
    if (_vehicleClass isEqualTo "" || _name isEqualTo "") then {
        WARNING_1("VehicleCosmetics","Cosmetic entry '%1' has no vehicle or no name - skipped",configName _entry);
        continue;
    };

    _out pushBack [_vehicleClass, _name, [getText (_entry >> "icon"), compile _code]];
} forEach (configProperties [_root, "isClass _x", true]);

INFO_1("VehicleCosmetics","%1 cosmetic entries read from the mission config.",count _out);

missionNamespace setVariable [QGVAR(cosmeticCache), _out];

_out
