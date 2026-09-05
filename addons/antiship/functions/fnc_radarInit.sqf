#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_antiship_fnc_radarInit

Description:
    Brings one surface search radar on the air.

    The radar exists because a coastal battery that can see the sea is a battery
    you find by looking at the sea. The launchers sit inland behind terrain with
    no line of sight to the water at all; this is the thing that looks, and the
    thing worth killing. Sync radars to the battery module the same way the
    launchers are synced - a battery with radars synced sees ONLY what they see,
    and a battery with none falls back to looking for itself.

    Registration only. The sweep itself is one server-side loop over every
    registered set (FUNC(radarSweep)) rather than a handler each: a coastline
    can carry a dozen of these and twelve timers to do one job is eleven too
    many.

Parameters:
    0: OBJECT - the radar.

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_radar", objNull, [objNull]]];
if (!isServer || {isNull _radar}) exitWith {};
if (_radar getVariable [QGVAR(registered), false]) exitWith {};
_radar setVariable [QGVAR(registered), true];

_radar setVariable [QGVAR(contacts), []];
// Whether the set is radiating right now. Server-local: nothing reads it yet -
// the EW and hacking addons will, to make an emitting radar findable by
// direction finding and its network hackable, which is the whole point of
// giving it a duty cycle. When a client-side reader exists, broadcast it here
// AND in FUNC(radarSweep); until then a public variable on every EMCON flip is
// network traffic for nobody.
_radar setVariable [QGVAR(radiating), false];

// Stagger the duty cycles. Left in step, every radar on the coast would go
// quiet at the same moment and the sea would blink.
_radar setVariable [QGVAR(emconOffset), random (AS_RADAR_ON + AS_RADAR_OFF)];

private _all = missionNamespace getVariable [QGVAR(radars), []];
_all pushBackUnique _radar;
// BROADCAST, like QGVAR(batteries) below it - the hacking console reads
// this list on CLIENTS to decide whether LOCATE RADAR is on offer, and an
// unbroadcast registry meant the product never appeared for remote players.
missionNamespace setVariable [QGVAR(radars), _all, true];

if (isNil QGVAR(sweepHandle)) then {
    missionNamespace setVariable [QGVAR(sweepHandle),
        [FUNC(radarSweep), AS_RADAR_TICK, []] call CBA_fnc_addPerFrameHandler];
};
