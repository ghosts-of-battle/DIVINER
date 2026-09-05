#include "script_component.hpp"
ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// THE QUICK CONNECT SETTINGS ARE MIRRORED INTO THE PROFILE, because the main
// menu is drawn before preInit has ever run and cannot read them where they
// live - see FUNC(cacheServers). Both halves of that are here rather than
// fifteen times over in initSettings.inc.sqf, which has no business knowing
// what reads it.
//
// Once at settings init, for the player who never opens Addon Options: the
// shipped defaults, into the profile, the first time a mission gets far enough
// for settings to exist.
[{[] call FUNC(cacheServers)}] call EFUNC(common,runAfterSettingsInit);

// And again whenever one of them is edited. One handler for all fifteen - they
// all share the QGVAR(server) prefix, and every one of them ends up in the same
// cache anyway.
["CBA_SettingChanged", {
    params ["_setting"];

    if ((_setting select [0, count QGVAR(server)]) isEqualTo QGVAR(server)) then {
        [] call FUNC(cacheServers);
    };
}] call CBA_fnc_addEventHandler;

ADDON = true;
