#include "script_component.hpp"
/*
 * Author: YonV
 * Checks if the given unit is inside a staging zone.
 * Unlike checkStagingZone this takes any unit and works on any machine,
 * since the zone list is built per-machine by init_staging.
 *
 * Arguments:
 * 0: Unit <OBJECT> (Optional; default: player)
 *
 * Return:
 * In staging zone <BOOL>
 *
 * Example:
 * [bob] call ghostD_systems_fnc_isInStagingZone
 * [player] call ghostD_systems_fnc_isInStagingZone
 */

params [["_unit", player, [objNull]]];

if (isNull _unit) exitWith { false };
if !(missionNamespace getVariable [QEGVAR(Mission,stagingZonesEnabled), true]) exitWith { false };
if (missionNamespace getVariable [QEGVAR(Staging,ZoneStatus), false]) exitWith { true };

private _stagingZones = missionNamespace getVariable [QEGVAR(Staging,Zones), []];

_stagingZones findIf {
    _x params ["_zone", "_size", "_type"];
    if (_type isEqualType objNull) then {
        _unit distance _zone <= (_size#0)
    } else {
        _unit inArea _zone && {(getPosVisual _unit)#2 <= 30}
    }
} > -1
