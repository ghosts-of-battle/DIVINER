#include "script_component.hpp"

ADDON = false;
LOG(MSG_INIT);

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Server-authoritative registry of live patrol bases.
// Each entry: [beacon, name, side, marker, kitCount]
if (isNil QGVAR(bases)) then {
    GVAR(bases) = [];
};

#include "initSettings.inc.sqf"

ADDON = true;
