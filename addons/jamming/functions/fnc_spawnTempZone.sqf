#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_jamming_fnc_spawnTempZone

Description:
    Registers an abstract jamming zone with no emitter object - used by the
    remote-hack failure package. It goes into the same registry the module's own
    emitters live in, so it is jammed by the same loop, seen by the same RDF
    scan, and obeys the same propagation model. There is no second code path for
    "temporary" jamming.

    Because it has no object, nothing can destroy it: it deregisters itself when
    its duration expires.

Parameters:
    _pos      : ARRAY  - centre.
    _radius   : NUMBER - outer radius; the full-strength core is the usual fraction of it.
    _duration : NUMBER - seconds before it removes itself.

Returns:
    STRING - the zone id, "" on failure.

Example:
    [getPosASL _hacker, 1200, 600] call ghostD_jamming_fnc_spawnTempZone

Author:
    Ghost
---------------------------------------------------------------------------- */
if (!isServer) exitWith { "" };

params [["_pos", [0,0,0], [[]]], ["_radius", 800, [0]], ["_duration", 600, [0]]];

if (isNil QGVAR(jammers)) then { GVAR(jammers) = [] };
if (isNil QGVAR(nextZoneId)) then { GVAR(nextZoneId) = 1 };

private _id = format [QGVAR(tmp%1), GVAR(nextZoneId)];
GVAR(nextZoneId) = GVAR(nextZoneId) + 1;

GVAR(jammers) pushBack [
    objNull, _radius * JAMMER_EFFECTIVE_FRAC, _radius,
    _id, "jam", true, _pos,
    [] call FUNC(zoneModel)
];
[] call FUNC(publishZones);

INFO_3("Jamming: temp jam zone %1 at %2 for %3s",_id,mapGridPosition _pos,_duration);

[{
    params ["_id"];
    GVAR(jammers) = GVAR(jammers) select { (_x param [ZONE_ID, ""]) isNotEqualTo _id };
    [] call FUNC(publishZones);
    INFO_1("Jamming: temp jam zone %1 expired",_id);
}, [_id], _duration] call CBA_fnc_waitAndExecute;

_id
