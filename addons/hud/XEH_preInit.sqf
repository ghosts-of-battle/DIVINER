#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// WHICH READOUT EACH SLOT IS SHOWING, as an index into the slot's own list -
// see FUNC(slotState). Held in profileNamespace rather than here so a player who
// has set the left slot to the squad list still has it there next mission; a HUD
// that forgets what it was showing is one that gets set up once and then ignored.
GVAR(slots) = [
    profileNamespace getVariable [QGVAR(slot_left), 4],
    profileNamespace getVariable [QGVAR(slot_right), 3]
];

// When the layer was last raised, so the tick knows when to renew it.
GVAR(raisedAt) = -1e9;

ADDON = true;
