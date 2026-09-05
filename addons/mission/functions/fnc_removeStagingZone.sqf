#include "script_component.hpp"
/*
 * Author: YonV
 * Removes a staging zone (identified by its object) from this client's local
 * staging-zone list. Companion to ghostD_mission_fnc_addStagingZone for teardown.
 * Object-type zones create no marker, so nothing else needs cleaning up.
 *
 * Arguments:
 * 0: Zone object <OBJECT> (the beacon passed to addStagingZone)
 *
 * Return Value: NONE
 */

params [["_zoneObj", objNull, [objNull]]];
if (isNull _zoneObj) exitWith {};

private _zones = missionNamespace getVariable [QEGVAR(Staging,Zones), []];
private _keep = _zones select {(_x select 0) isNotEqualTo _zoneObj};
missionNamespace setVariable [QEGVAR(Staging,Zones), _keep];
