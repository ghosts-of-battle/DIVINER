#include "script_component.hpp"

// The point list lives in missionNamespace and is published, so a JIP client
// gets it with the rest of the mission state rather than needing a handshake.
if (isServer && {isNil QTP_LIST}) then {
    TP_LIST = [];
    publicVariable QTP_LIST;
};

[] call FUNC(zenModules);

// NO Rev_tp_fnc_* ALIASES HERE, DELIBERATELY. They existed while the Roomba
// mission.sqm was binarised and its Eden init fields could not be edited; the
// sqm is text now and calls the ghost names directly.
//
// AND THEY WERE ACTIVELY DANGEROUS. Nine other missions in this collection
// still ship Reeveli's original scripts\Rev_teleport and define their own
// Rev_tp_fnc_* through their own CfgFunctions - a mod-side assignment at init
// would have overwritten a mission's own copy with ghost's.
