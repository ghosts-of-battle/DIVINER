#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_uas_fnc_zonesFor

Description:
    The patrol zones one side flies over.

    ONE MODULE IS ONE PATROL. Each entry is a Ghost - Drone Patrol module and
    carries everything that patrol needs - where, how big, which airframe, how
    many of it, and whether it calls artillery on what it sees. Nothing is
    shared between two modules, which is the point: two Darters over the port
    and one Sentinel over the pass is two modules set differently.

    THE INDEX IS THE IDENTITY. It is the entry's place in QGVAR(zones), stamped
    on every airframe the zone launches - FUNC(planPatrols) counts what a zone
    already has by it, and FUNC(spotSweep) reads the artillery option back
    through it. Zones are only ever appended, so an index is stable.

    THE FIRST THREE ARE THE OLD OBJECTIVE LIST'S, deliberately. This stands
    where ghostD_adapter_alive_fnc_objectivesFor stood, and the consumers that
    only wanted a position - FUNC(topUp) reading `_x select 1` - did not have to
    change at all.

    NOT SORTED HERE. An array whose first element is a SIDE cannot be `sort`ed:
    the comparison starts at index 0 and SIDE is not an orderable type.

Parameters:
    0: SIDE - whose zones.

Returns:
    ARRAY - [[side, pos, radius, index, class, count, arty], ...]
            arty is [on, rounds, scatter, cooldown].

Author:
    YonV
---------------------------------------------------------------------------- */
params [["_side", sideUnknown, [sideUnknown]]];

private _out = [];

{
    _x params ["_zSide", "_pos", "_radius", "_class", "_count", "_arty"];
    if (_zSide isEqualTo _side) then {
        _out pushBack [_zSide, _pos, _radius, _forEachIndex, _class, _count, _arty];
    };
} forEach (missionNamespace getVariable [QGVAR(zones), []]);

_out
