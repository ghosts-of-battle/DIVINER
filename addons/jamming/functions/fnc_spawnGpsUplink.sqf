#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_jamming_fnc_spawnGpsUplink

Description:
    Stands up the GPS denial: one ground uplink at an enemy objective, and the
    wandering sphere overhead that the uplink steers.

    TWO ZONES, ONE SWITCH. The uplink is an ordinary emitter - a real object at
    a real place, hackable and destructible like the hub and the terminal, and
    plotted by LOCATE JAMMER because it lives in the same registry every other
    consumer already walks. The sphere is abstract: nothing to find, nothing to
    shoot, drifting over the map on its own. Killing the uplink kills the
    sphere with it (see FUNC(gpsDrift)), which is the whole shape of the thing -
    GPS denial is the one field a player cannot walk out of, so it has to have
    somewhere to be walked INTO instead.

    WHY THE SPHERE IS ABSTRACT AND NOT A PROP. It is space-based. Putting an
    object under it would be a lie the players could shoot, and would anchor a
    thing that is supposed to wander.

    ONE PER SIDE, NOT ONE PER OBJECTIVE. The hub and terminal scale with the
    objective count because a comms net is many masts; a constellation is not.
    A commander gets one uplink or none.

Parameters:
    _side   : SIDE   - the commander this uplink belongs to.
    _pos    : ARRAY  - where the uplink stands, AGL.

Returns:
    ARRAY - [_uplinkId, _sphereId, _uplinkObject]. The two ids are "" and the
            object objNull on failure. The object is returned because a placed
            Jammer Site module hangs its artillery reply on the emitter, and the
            uplink is an emitter like any other.

Author:
    Ghost
---------------------------------------------------------------------------- */
if (!isServer) exitWith { [ARR_3("","",objNull)] };

params [["_side", sideUnknown, [sideUnknown]], ["_pos", [0,0,0], [[]]]];

// --- the uplink -------------------------------------------------------------
// A jammer site like the other two - hub terminal, omni antenna, dish, and an
// ALiVE objective over the lot - so it is garrisoned, findable and hackable
// with no extra wiring here. FUNC(spawnJammerSite) owns the prop check, so a
// mod set without the hub terminal loses GPS denial and keeps the rest.
//
// It denies GPS locally as well as steering the sphere, which is not
// decoration: it means a player closing on the uplink to destroy it does the
// last four hundred metres with no GPS and no self-icon, which is the fight the
// whole system exists to create.
([_side, _pos, DOM_GPS, GVAR(gpsUplinkRadius)] call FUNC(spawnJammerSite)) params ["_upId", "_upObj"];
if (_upId isEqualTo "") exitWith { [ARR_3("","",objNull)] };

// --- the sphere -------------------------------------------------------------
// Rolled between the two radii rather than averaged: a 1 km field and a 2 km
// field are different problems, and a mission should get one or the other.
private _r = [GPS_SPHERE_R_A, GPS_SPHERE_R_B] select (random 1 < 0.5);

// It starts somewhere else entirely. Over the uplink it would read as a dome
// on the objective, which is the ground-based shape this is deliberately not.
private _world = worldSize;
private _start = [
    GPS_EDGE_MARGIN + random (_world - 2 * GPS_EDGE_MARGIN),
    GPS_EDGE_MARGIN + random (_world - 2 * GPS_EDGE_MARGIN),
    0
];

if (isNil QGVAR(nextZoneId)) then { GVAR(nextZoneId) = 1 };
private _sphereId = format [QGVAR(gps%1), GVAR(nextZoneId)];
GVAR(nextZoneId) = GVAR(nextZoneId) + 1;

// isTemp = true, which is what tells FUNC(jamFactor) to skip the alive check on
// a null object. It is not temporary in the sense spawnTempZone means - nothing
// expires it - but the flag's real job is "this zone has no object", and that
// is exactly true here.
private _model = [[DOM_GPS]] call FUNC(zoneModel);
_model set ["heldBy", _upId];
_model set ["driftDir", random 360];

GVAR(jammers) pushBack [
    objNull, _r * JAMMER_EFFECTIVE_FRAC, _r,
    _sphereId, "jam", true, AGLToASL _start,
    _model
];

[] call FUNC(publishZones);

INFO_3("GPS denial up: uplink %1 at %2, sphere r=%3",_upId,mapGridPosition _pos,round _r);

// The drift is what moves it and what notices the uplink dying.
[_sphereId] call FUNC(gpsDrift);

[_upId, _sphereId, _upObj]
