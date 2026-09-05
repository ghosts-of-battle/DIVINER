#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_common_fnc_setDatalink

Description:
    Puts a vehicle on its side's sensor network.

    Since the Tanks/Encore sensor overhaul Arma has a real datalink: a vehicle
    that REPORTS pushes its contacts to everyone on its side who RECEIVES, and
    the receivers can then engage what they cannot see themselves. Without this,
    a recon drone orbiting overhead is worth nothing to the AA site two ridges
    away - it sees, and tells nobody.

    Both flags are set rather than split by role. The intent is that recon feeds
    shooters, but the split costs more than it buys: an armed drone carries
    sensors too and its contacts are just as useful, while receiving on an
    unarmed airframe is inert - it has nothing to shoot with. Setting both is a
    superset of the useful behaviour with no downside, and it means nothing has
    to guess which airframes count as "armed", a question with no reliable
    config answer once mods are involved.

    Own-position reporting puts the airframe itself on its side's datalink, which
    is what lets a commander see where his own drone is.

    Must run where the vehicle is local; the effect is global.

Parameters:
    _veh    : OBJECT - the vehicle.
    _report : BOOL   - broadcast contacts. Optional, default true.
    _recv   : BOOL   - receive contacts. Optional, default true.
    _own    : BOOL   - broadcast own position. Optional, default true.

Example:
    [_drone] call ghostD_common_fnc_setDatalink

Author:
    Ghost
---------------------------------------------------------------------------- */
params [["_veh", objNull, [objNull]], ["_report", true, [false]],
        ["_recv", true, [false]], ["_own", true, [false]]];

if (isNull _veh) exitWith {};

_veh setVehicleReportRemoteTargets _report;
_veh setVehicleReceiveRemoteTargets _recv;
_veh setVehicleReportOwnPosition _own;
