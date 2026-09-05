#include "script_component.hpp"
ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// The vehicle-pointing throttle reads this before it first writes it - the
// first press threw on nil + 1 and self-healed after, masking itself.
GVAR(lastPointTime) = -1;

ADDON = true;
