#include "script_component.hpp"
/*
 * Author: YonV
 * Restricts marking on the vanilla map:
 *  - Players may draw and place icons in the DIRECT channel only (personal, close-proximity).
 *  - Markers in any other channel (global/side/command/group/vehicle) must be placed
 *    through a cTab (cTabIRL tacmap, name contains "/tacmap") or by an admin
 *    (admin panel list or logged-in server admin, e.g. importing map data).
 * Script/Zeus markers (not "_USER_DEFINED") are never touched.
 *
 * Example:
 * call ghostD_init_fnc_mapDrawing
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

#define CHANNEL_DIRECT 5

addMissionEventHandler ["MarkerCreated", {
    params ["_marker", "_channelNumber", "_owner", "_local"];

    if (!_local) exitWith {};                        // only police markers created on this machine
    if !("_USER_DEFINED" in _marker) exitWith {};    // ignore script/Zeus markers
    if (_channelNumber == CHANNEL_DIRECT) exitWith {}; // direct channel - personal marking allowed

    if (call BIS_fnc_admin > 0) exitWith {};         // logged-in/voted server admin
    if (!isNil "admp_fnc_isAdmin" && {[player] call admp_fnc_isAdmin}) exitWith {};

    deleteMarker _marker;
    [
        "Map Marking",
        "Limited to the DIRECT channel. Use TAC//PAD to share markers with your side or group.",
        NOTE_BAD
    ] call GHOSTFUNC(notify,notify);
}];
