#include "script_component.hpp"
/*
 * Author: Jacco Douma, Ghost
 * The CfgMarkers side letter a group's icon is built from. Automatic reads the
 * group's side; anything else forces one shape on every group there is, which is
 * why the setting warns about enemy markers.
 *
 * Arguments:
 * 0: Group <GROUP>
 *
 * Return Value:
 * Marker side letter, "b" / "o" / "n" <STRING>
 *
 * Example:
 * [group player] call ghostD_bft_fnc_getGroupMarkerShape
 *
 * Public: No
 */

params ["_group"];

// Not automatic: the mission maker has picked one shape for everything.
if (GVAR(markerShape) isNotEqualTo "a") exitWith {GVAR(markerShape)};

private _markerSide = "b";
if (side _group isEqualTo east) then {_markerSide = "o"};
if (side _group isEqualTo independent) then {_markerSide = "n"};

_markerSide
