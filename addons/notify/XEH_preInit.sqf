#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// THE LOG. Every notification shown is kept here for the tacpad reader's LOG
// view - [title, text, colour, time, pos]. pos is [] unless the caller passed
// one; an entry with a pos is clickable in the reader and centres the map.
GVAR(history) = [];

ADDON = true;
