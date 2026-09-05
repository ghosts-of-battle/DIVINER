#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// The registries both halves of the addon write into, declared before anything
// can be created - a launcher placed in Eden runs its init before postInit, and
// pushBack onto nil is not a battery.
GVAR(batteries) = [];
GVAR(radars) = [];

#include "initSettings.inc.sqf"

ADDON = true;
