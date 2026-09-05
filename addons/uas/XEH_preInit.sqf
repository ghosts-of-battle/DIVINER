#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

#include "initSettings.inc.sqf"

// ARMED FLAG, DECLARED AT PREINIT. Module functions run BETWEEN preInit and
// postInit, so declaring this in postInit was wrong twice over: the module
// read it before it existed, and postInit then set it back to false AFTER the
// module had armed the system.
GVAR(moduleUp) = false;

// The zones somebody has drawn. Declared here for the same reason moduleUp is:
// a module function runs before postInit, and pushBack onto nil is not a zone.
GVAR(zones) = [];

// When each zone last called artillery, keyed by its index in GVAR(zones).
GVAR(artyLast) = createHashMap;

#include "initSettings.inc.sqf"

ADDON = true;
