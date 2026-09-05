#include "script_component.hpp"
/*
 * Author: Ghost
 * THE MISSION HAS HANDED ITS CONFIGS OVER - build the databases from them.
 *
 * THIS EXISTS BECAUSE OF THE ORDER CBA RUNS THINGS IN. Extended_PreInit
 * handlers from addons (configFile) run BEFORE the ones from the mission
 * (missionConfigFile), so this addon's own preInit is always too early: it asks
 * for ghostFR_missionConfig_* before the mission's config\loadConfigs.sqf has set
 * them. Building at preInit alone would give every mission an empty logistics
 * database and no pylons, silently.
 *
 * So the mission calls this the moment its data is ready, and preInit calls it
 * too. Whichever happens first does the work; the second finds it already done.
 * A mission that hands nothing over gets empty databases and says so once,
 * which is the right answer for a mission that carries no catalogues.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * The databases were built from real data <BOOL>
 *
 * Example:
 * call ghostD_init_fnc_missionConfigsReady
 *
 * Public: Yes
 */

// IDEMPOTENT ON PURPOSE - see above, this is called from two places by design
// and the second caller must not rebuild what the first already built.
if (GVAR(configsBuilt)) exitWith {false};

private _haveLogistics = (missionNamespace getVariable ["ghostFR_missionConfig_logistics", []]) isNotEqualTo [];
private _havePylons = (missionNamespace getVariable ["ghostFR_missionConfig_pylons", []]) isNotEqualTo [];

// NOTHING YET IS NOT AN ERROR. preInit reaches here before the mission's own
// handler has run, every time. It leaves the flags down and returns; the
// mission's call is the one that finds the data and does the work.
if (!_haveLogistics && {!_havePylons}) exitWith {false};

GVAR(configsBuilt) = true;

// THE FLAGS BRACKET THE BUILD so a consumer that starts early can tell
// "not built yet" from "built and empty".
EGVAR(DATABASE,DONE) = false;
GVAR(DATABASE) = call FUNC(logistics);
EGVAR(DATABASE,DONE) = true;

EGVAR(PYLONS,DONE) = false;
GVAR(PYLONS) = call FUNC(pylons);
EGVAR(PYLONS,DONE) = true;

// The skill block is the mission's own compiled code - see FUNC(skillAdjustment).
if (EGVAR(Settings,setAiSystemDifficulty) >= 1) then {
    call FUNC(skillAdjustment);
};

INFO_2("preInit","Mission configs built - %1 logistics entries and %2 pylon vehicles.",count GVAR(DATABASE),count GVAR(PYLONS));

true
