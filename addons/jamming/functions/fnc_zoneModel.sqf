#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_jamming_fnc_zoneModel

Description:
    Builds the propagation model stamped onto a zone at spawn. Every field
    defaults to the behaviour the addon had before the model existed, so a
    mission that sets none of the new attributes jams exactly as it always did.

    Cone bearing is rolled here, once, per zone - a directional jammer that
    re-rolled its arc every tick would be unplayable.

Parameters:
    _domains : ARRAY - which of DOM_RADIO / DOM_DATA / DOM_GPS this zone denies.
                       Optional, default DOM_DEFAULT (radio and data), which is
                       what a single emitter denied before the domains existed.

Returns:
    HASHMAP - domains, los, burnthrough, burnRef, curve, duty, coneFrom,
              coneArc, jamUavs

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_domains", DOM_DEFAULT, [[]]]];

// An empty list would be a zone that denies nothing - a silent no-op that looks
// like a working emitter on the map. Read it as "the caller did not say".
if (_domains isEqualTo []) then { _domains = DOM_DEFAULT };

private _cone = GVAR(jamConeEnable);

createHashMapFromArray [
    ["domains",     _domains],
    ["los",         GVAR(jamLos)],
    ["burnthrough", GVAR(jamBurnthrough)],
    ["burnRef",     GVAR(jamBurnRef)],
    ["curve",       GVAR(jamCurve)],
    ["duty",        GVAR(jamDuty)],
    ["coneFrom",    if (_cone) then { random 360 } else { -1 }],
    ["coneArc",     if (_cone) then { 60 + random 120 } else { 360 }],
    ["jamUavs",     GVAR(jamUavs)]
]
